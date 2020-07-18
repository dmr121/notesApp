//
//  NoteView.swift
//  notes
//
//  Created by David Rozmajzl on 7/16/20.
//  Copyright © 2020 David Rozmajzl. All rights reserved.
//

import SwiftUI

struct NoteView: View {
    
    var title: String
    var noteBody: String
    var created: Date
    var modified: Date
    var buttonAction: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false){
                        Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    }
                    Spacer()
                    
                    Button(action: {
                        self.buttonAction()
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                            .font(.system(size: 20, weight: .semibold, design: .default))
                    }
                    .padding([.leading, .bottom], 16)
                }
                
                HStack {
                    Text(noteBody)
                        .font(.body)
                        .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                    Spacer()
                }
                .padding(.bottom, 8)
                
                HStack {
                    Text("Last Modified: \(displayDate(with: modified))")
                        .font(.body)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension NoteView {
    func displayDate(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateString = formatter.string(from: date)
        return dateString
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(title: "Title", noteBody: "body this is a body that i wrote and it is as very good body but to be completely honest it is very gramatically incorrect but that doesn't mattter because this will never see production", created: Date(), modified: Date(), buttonAction: {
            print("fuck this function")
        })
    }
}
