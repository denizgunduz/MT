//
//  NavigationViewModifier.swift
//  Dot
//
//  Created by Alex Nagy on 09.08.2021.
//

import SwiftUI

public struct NavigationViewModifier: ViewModifier {
    
    @ObservedObject public var navigation: Navigation
    
    public func body(content: Content) -> some View {
        content
            .background(
                NavigationLink(
                    destination:
                        navigation.destination
                        .onDisappear {
                            navigation.onDismiss?()
                        },
                    isActive:
                        $navigation.isPushed,
                    label: {
                        EmptyView()
                    })
            )
            .sheet(isPresented: $navigation.isPresented, onDismiss: navigation.onDismiss) {
                navigation.destination
            }
            .fullScreenCover(isPresented: $navigation.isCovered, onDismiss: navigation.onDismiss) {
                navigation.destination
            }
    }
}

public extension View {
    func uses(_ navigation: Navigation) -> some View {
        modifier(NavigationViewModifier(navigation: navigation))
    }
}
