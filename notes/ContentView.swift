//
//  ContentView.swift
//  notes
//
//  Created by David Rozmajzl on 7/15/20.
//  Copyright © 2020 David Rozmajzl. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: UI Variables
    @State var noteBody: String = ""
    @State var noteTitle: String = ""
    @State var noteCreated: Date = Date()
    @State var noteModified: Date = Date()
    @State var noteBeingEdited = Note(entity: Note.entity(), insertInto: nil)
    
    var charLimit = 240
    @State var noteTitleAlert = false
    @State var noteBodyAlert = false
    @State var noteDeleteAlert = false
    @State var makingNewNote = false
    @State var editingNote = false
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Note.modified, ascending: false)
        ]
    ) var notes: FetchedResults<Note>
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(notes, id: \.id) { note in
                        NoteView(title: note.title!, noteBody: note.body!, created: note.created!, modified: note.modified!, buttonAction: {
                            self.deleteNote(note: note)
                        })
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                self.noteBody = note.body!
                                self.noteTitle = note.title!
                                self.noteModified = note.modified!
                                self.noteCreated = note.created!
                                self.noteBeingEdited = note
                                self.editingNote.toggle()
                        }
                    }
                }
                .padding(.bottom, 16)
                .navigationBarTitle("Notes")
                .navigationBarItems(trailing:
                    Button(action: {
                        self.makingNewNote.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24, weight: .semibold, design: .default))
                    }
                    .padding([.leading, .bottom], 16)
                )
                    .edgesIgnoringSafeArea(.bottom)
            }
            .blur(radius: (makingNewNote || editingNote) ? 10 : 0)
            .animation(.easeInOut)
            .accentColor(.yellow)
            .disabled(makingNewNote || editingNote)
            
            VStack{
                VStack {
                    HStack {
                        TextField("Untitled Note", text: $noteTitle, onCommit: {
                            
                        })
                            .font(Font.system(size: 30, weight: .bold, design: .default))
                            .alert(isPresented: $noteTitleAlert) {
                                Alert(
                                    title: Text("Blank Title"),
                                    message: Text("Make sure you give your note a title."),
                                    dismissButton: .default(Text("OK"))
                                )
                        }
                        
                        Button(action: {
                            self.makingNewNote = false
                            self.editingNote = false
                            self.hideKeyboard()
                            self.noteTitle = ""
                            self.noteBody = ""
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                                .font(.system(size: 20, weight: .semibold, design: .default))
                        }
                        .padding([.leading, .bottom], 16)
                    }
                    .padding(12)
                    
                    HStack (alignment: .top){
                        Image(systemName: "keyboard")
                            .foregroundColor(Color(#colorLiteral(red: 0.3332922161, green: 0.3333563209, blue: 0.3332930207, alpha: 1)))
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .padding(.top, 12)
                        MultilineTextFieldView("", text: $noteBody, characterLimit: charLimit, onCommit: {
                            
                        })
                            .alert(isPresented: $noteBodyAlert) {
                                Alert(
                                    title: Text("Blank Body"),
                                    message: Text("Make sure you give your note some content."),
                                    dismissButton: .default(Text("OK"))
                                )
                        }
                        .animation(.none)
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .animation(.none)
                    .background(Color(#colorLiteral(red: 0.9131512046, green: 0.9133043885, blue: 0.9131310582, alpha: 1)))
                    
                    
                    HStack (alignment: .top) {
                        Text("\(charLimit - noteBody.count) Characters Remaining")
                            .font(.footnote)
                            .foregroundColor(Color(#colorLiteral(red: 0.7686134577, green: 0.7685713768, blue: 0.7771573663, alpha: 1)))
                            .offset(x: 1, y: 0)
                            .animation(.none)
                        
                        Spacer().animation(.none)
                        
                        if makingNewNote {
                            Button(action: {
                                if self.saveNewItem() {
                                    self.makingNewNote = false
                                    self.hideKeyboard()
                                    self.noteTitle = ""
                                    self.noteBody = ""
                                }
                            }) {
                                HStack {
                                    Text("Add")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                }
                                .padding(.vertical ,4)
                                .padding(.horizontal, 10)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }.animation(.none)
                        } else if editingNote {
                            Button(action: {
                                if self.saveEditedItem() {
                                    self.editingNote = false
                                    self.hideKeyboard()
                                    self.noteTitle = ""
                                    self.noteBody = ""
                                }
                            }) {
                                HStack {
                                    Text("Save")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Image(systemName: "folder.badge.plus.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                }
                                .padding(.vertical ,4)
                                .padding(.horizontal, 10)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }.animation(.none)
                        }
                    }
                    .animation(.none)
                    .padding(12)
                    
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 10)
                .padding()
                .accentColor(.yellow)
                .offset(x: 0, y: (makingNewNote || editingNote) ? 0 : -300)
                .animation(.spring())
                
                Spacer()
                    .animation(.none)
            }
            
            //            VStack {
            //                Spacer()
            //                Button(action: {
            //                    self.noteJustDeleted = false
            //                    self.undoDelete()
            //                }) {
            //                    HStack {
            //                        Text("Undo")
            //                            .foregroundColor(.white)
            //                            .fontWeight(.semibold)
            //                        Image(systemName: "arrow.uturn.left.circle")
            //                            .foregroundColor(.white)
            //                            .font(.system(size: 18, weight: .semibold, design: .default))
            //                    }
            //                    .padding(.vertical ,6)
            //                    .padding(.horizontal, 12)
            //                    .background(Color.gray)
            //                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            //                }
            //            }
            //            .offset(x: 0, y: noteJustDeleted ? 0 : 100)
            //            .animation(.spring())
            //            .blur(radius: (makingNewNote || editingNote) ? 10 : 0)
            //            .animation(.easeInOut)
            //            .disabled(makingNewNote || editingNote)
        }
    }
}

// MARK: Functions
extension ContentView {
    func saveNewItem() -> Bool {
        
        if noteTitle.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            noteTitleAlert = true
            return false
        }
        
        if noteBody.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            noteBodyAlert = true
            return false
        }
        
        let item = Note(context: context)
        item.title = noteTitle
        item.body = noteBody
        item.created = Date()
        item.modified = Date()
        item.id = UUID()
        try? context.save()
        return true
    }
    
    func saveEditedItem() -> Bool {
        
        if noteTitle.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            noteTitleAlert = true
            return false
        }
        
        if noteBody.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            noteBodyAlert = true
            return false
        }
        
        noteBeingEdited.title = noteTitle
        noteBeingEdited.body = noteBody
        noteBeingEdited.modified = Date()
        try? context.save()
        return true
    }
    
    func deleteNote(note : Note) {
        context.delete(note)
        do {
            try context.save()
        } catch {
            print("Core Data Error")
        }
    }
    
    func displayDate(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
