//
//  SwiftUIView.swift
//  Milo
//
//  Created by Hendra Irawan on 16/06/26.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.system(size: 20)
                .bold(true))
            .foregroundColor(.red)
            .padding()
        Image(systemName: "circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
                
    }
    
}

#Preview {
    SwiftUIView()
}
