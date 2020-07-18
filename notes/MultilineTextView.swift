//
//  MultilineTextFieldView.swift
//  30DayPassion
//
//  Created by David Rozmajzl on 5/30/20.
//  Copyright © 2020 David Rozmajzl. All rights reserved.
//

import SwiftUI

struct MultilineTextFieldView: View {

    private var placeholder: String
    private var characterLimit: Int?
    private var onCommit: (() -> Void)?
    @State private var viewHeight: CGFloat = 40 //start with one line
    @State private var shouldShowPlaceholder = false
    @Binding private var text: String
    
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.shouldShowPlaceholder = $0.isEmpty
        }
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $viewHeight, characterLimit: characterLimit, onDone: onCommit)
            .frame(minHeight: viewHeight, maxHeight: viewHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if shouldShowPlaceholder {
                Text(placeholder).foregroundColor(Color(#colorLiteral(red: 0.7686134577, green: 0.7685713768, blue: 0.7771573663, alpha: 1)))
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
    
    init (_ placeholder: String = "", text: Binding<String>, characterLimit: Int? = nil, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self.characterLimit = characterLimit
        self._shouldShowPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

}


private struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var characterLimit: Int?
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.autocorrectionType = .no
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.returnKeyType = .done
        textField.textColor = UIColor.darkGray
        textField.tintColor = UIColor.systemYellow
        if nil != onDone {
            textField.returnKeyType = .continue
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    private static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // call in next render cycle.
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, characterLimit: characterLimit, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        var characterLimit: Int?

        init(text: Binding<String>, height: Binding<CGFloat>, characterLimit: Int? = nil, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
            self.characterLimit = characterLimit
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            
            if characterLimit == nil {
                return true
            } else {
                // The following lines limit the text a user can type to 140 characters
                
                // get the current text, or use an empty string if that failed
                let currentText = textView.text ?? ""

                // attempt to read the range they are trying to change, or exit if we can't
                guard let stringRange = Range(range, in: currentText) else { return false }

                // add their new text to the existing text
                let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

                // make sure the result is under 16 characters
                return updatedText.count <= characterLimit!
            }
        }
    }

}

struct MultilineTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
