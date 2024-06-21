//
//  BackgroundAnimation.swift
//  BackgroundAnimationSwiftUI
//
//  Created by japsa on 21.06.2024.
//

import SwiftUI

import SwiftUI

struct BackgroundAnimation: View {

    private enum AnimationProperties {
        static let animationSpeed: Double = 4
        static let timerDuration: TimeInterval = 3
        static let blurRadius: CGFloat = 130
    }

    @State private var timer = Timer.publish(every: AnimationProperties.timerDuration, on: .main, in: .common).autoconnect()
    @ObservedObject private var animator = CircleAnimator(colors: BackgroundColors.all)

    var body: some View {
        ZStack {
            ZStack {
                ForEach(animator.circles) { circle in
                    MovingCircle(originOffset: circle.position)
                        .foregroundColor(circle.color)
                }
            }.blur(radius: AnimationProperties.blurRadius)
        }
        .background(BackgroundColors.backgroundColor)
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            animateCircles()
            timer = Timer.publish(every: AnimationProperties.timerDuration, on: .main, in: .common).autoconnect()
        }
        .onReceive(timer) { _ in
            animateCircles()
        }
    }

    private func animateCircles() {
        withAnimation(.easeInOut(duration: AnimationProperties.animationSpeed)) {
            animator.animate()
        }
    }

}

private enum BackgroundColors {
    static var all: [Color] {
        [
            Color(red: 64/255, green: 224/255, blue: 208/255, opacity: 0.6), // Turquoise
            Color(red: 72/255, green: 61/255, blue: 139/255), // DarkSlateBlue
            Color(red: 135/255, green: 206/255, blue: 235/255, opacity: 0.7), // SkyBlue
            Color(red: 255/255, green: 182/255, blue: 193/255), // LightPink
            Color(red: 173/255, green: 216/255, blue: 230/255), // LightBlue
        ]
    }

    static var backgroundColor: Color {
        Color(red: 25/255, green: 25/255, blue: 112/255) // MidnightBlue
    }
}

private struct MovingCircle: Shape {

    var originOffset: CGPoint

    var animatableData: CGPoint.AnimatableData {
        get {
            originOffset.animatableData
        }
        set {
            originOffset.animatableData = newValue
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let adjustedX = rect.width * originOffset.x
        let adjustedY = rect.height * originOffset.y
        let smallestDimension = min(rect.width, rect.height)
        path.addArc(center: CGPoint(x: adjustedX, y: adjustedY), radius: smallestDimension/2, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        return path
    }
}

private class CircleAnimator: ObservableObject {
    class Circle: Identifiable {
        internal init(position: CGPoint, color: Color) {
            self.position = position
            self.color = color
        }
        var position: CGPoint
        let id = UUID().uuidString
        let color: Color
    }

    @Published private(set) var circles: [Circle] = []


    init(colors: [Color]) {
        circles = colors.map({ color in
            Circle(position: CircleAnimator.generateRandomPosition(), color: color)
        })
    }

    func animate() {
        objectWillChange.send()
        for circle in circles {
            circle.position = CircleAnimator.generateRandomPosition()
        }
    }

    static func generateRandomPosition() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0 ... 1), y: CGFloat.random(in: 0 ... 1))
    }
}


#Preview {
    BackgroundAnimation()
}
