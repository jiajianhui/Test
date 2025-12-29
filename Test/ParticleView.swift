//
//  ParticleView.swift
//  Test
//
//  Created by 贾建辉 on 2025/11/15.
//

import SwiftUI

// MARK: - 粒子发射器组件
struct ParticleEmitter: View {
    // 可自定义参数
    var emissionRate: Double = 0.08 // 发射频率（秒）
    var particleCount: Int = 1 // 每次发射粒子数
    var direction: EmissionDirection = .leftToRight // 发射方向
    var speed: ClosedRange<Double> = 20...100 // 速度范围
    var particleSize: ClosedRange<Double> = 0.5...2 // 粒子大小
    var colors: [Color] = [.white] // 粒子颜色
    var gravity: Double = 0 // 重力（0=无重力）
    var lifetime: ClosedRange<Double> = 6...10 // 生命周期
    var spread: Double = 10 // 扩散范围（角度或距离）
    var particleShape: ParticleShape = .circle // 粒子形状
    
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let age = now - particle.creationTime
                    
                    if age < particle.lifetime {
                        // 根据方向计算位置
                        let position = calculatePosition(
                            particle: particle,
                            age: age,
                            size: size
                        )
                        
                        // 计算透明度和缩放
                        let progress = age / particle.lifetime
                        let opacity = max(0, 1.0 - progress)
                        let scale = particle.size * (1.0 - progress * 0.3)
                        
                        context.opacity = opacity
                        
                        // 根据形状绘制
                        drawParticle(
                            context: context,
                            position: position,
                            scale: scale,
                            color: particle.color,
                            shape: particle.shape
                        )
                    }
                }
            }
        }
        .onAppear {
            startEmitting()
        }
        .onDisappear {
            stopEmitting()
        }
    }
    
    // MARK: - 绘制粒子
    private func drawParticle(context: GraphicsContext, position: CGPoint, scale: Double, color: Color, shape: ParticleShape) {
        switch shape {
        case .circle:
            let rect = CGRect(
                x: position.x - scale / 2,
                y: position.y - scale / 2,
                width: scale,
                height: scale
            )
            context.fill(
                Circle().path(in: rect),
                with: .color(color)
            )
            
        case .line(let length):
            let lineLength = length * scale
            let rect = CGRect(
                x: position.x - lineLength / 2,
                y: position.y - scale / 2,
                width: lineLength,
                height: scale
            )
            context.fill(
                RoundedRectangle(cornerRadius: scale / 2).path(in: rect),
                with: .color(color)
            )
            
        case .square:
            let rect = CGRect(
                x: position.x - scale / 2,
                y: position.y - scale / 2,
                width: scale,
                height: scale
            )
            context.fill(
                Rectangle().path(in: rect),
                with: .color(color)
            )
            
        case .star:
            let rect = CGRect(
                x: position.x - scale / 2,
                y: position.y - scale / 2,
                width: scale,
                height: scale
            )
            context.fill(
                StarShape().path(in: rect),
                with: .color(color)
            )
            
        case .heart:
            let rect = CGRect(
                x: position.x - scale / 2,
                y: position.y - scale / 2,
                width: scale,
                height: scale
            )
            context.fill(
                HeartShape().path(in: rect),
                with: .color(color)
            )
            
        case .triangle:
            let rect = CGRect(
                x: position.x - scale / 2,
                y: position.y - scale / 2,
                width: scale,
                height: scale
            )
            context.fill(
                TriangleShape().path(in: rect),
                with: .color(color)
            )
        }
    }
    
    // MARK: - 根据方向计算位置
    private func calculatePosition(particle: Particle, age: Double, size: CGSize) -> CGPoint {
        let baseX = particle.x + particle.velocityX * age
        let baseY = particle.y + particle.velocityY * age + 0.5 * gravity * age * age
        
        switch direction {
        case .leftToRight:
            return CGPoint(x: baseX, y: baseY)
        case .rightToLeft:
            return CGPoint(x: size.width - baseX, y: baseY)
        case .bottomToTop:
            return CGPoint(x: baseY, y: size.height - baseX)
        case .topToBottom:
            return CGPoint(x: baseY, y: baseX)
        case .circular(let center):
            let angle = particle.angle
            let radius = particle.velocityX * age
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }
    
    // MARK: - 开始发射
    private func startEmitting() {
        timer = Timer.scheduledTimer(withTimeInterval: emissionRate, repeats: true) { _ in
            emitParticles()
            cleanupOldParticles()
        }
    }
    
    // MARK: - 停止发射
    private func stopEmitting() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 发射粒子
    private func emitParticles() {
        for _ in 0..<particleCount {
            let particle: Particle
            
            switch direction {
            case .leftToRight:
                particle = Particle(
                    x: 0,
                    y: Double.random(in: 0...20) + spread * Double.random(in: -1...1),
                    velocityX: Double.random(in: speed),
                    velocityY: Double.random(in: -spread...spread),
                    angle: 0,
                    color: colors.randomElement()!,
                    size: Double.random(in: particleSize),
                    lifetime: Double.random(in: lifetime),
                    shape: particleShape
                )
                
            case .rightToLeft:
                particle = Particle(
                    x: 0,
                    y: Double.random(in: 0...300) + spread * Double.random(in: -1...1),
                    velocityX: Double.random(in: speed),
                    velocityY: Double.random(in: -spread...spread),
                    angle: 0,
                    color: colors.randomElement()!,
                    size: Double.random(in: particleSize),
                    lifetime: Double.random(in: lifetime),
                    shape: particleShape
                )
                
            case .bottomToTop:
                particle = Particle(
                    x: Double.random(in: 0...300),
                    y: 0,
                    velocityX: -Double.random(in: speed),
                    velocityY: Double.random(in: -spread...spread),
                    angle: 0,
                    color: colors.randomElement()!,
                    size: Double.random(in: particleSize),
                    lifetime: Double.random(in: lifetime),
                    shape: particleShape
                )
                
            case .topToBottom:
                particle = Particle(
                    x: Double.random(in: 0...300),
                    y: 0,
                    velocityX: Double.random(in: speed),
                    velocityY: Double.random(in: -spread...spread),
                    angle: 0,
                    color: colors.randomElement()!,
                    size: Double.random(in: particleSize),
                    lifetime: Double.random(in: lifetime),
                    shape: particleShape
                )
                
            case .circular(let center):
                let angle = Double.random(in: 0...(2 * .pi))
                particle = Particle(
                    x: center.x,
                    y: center.y,
                    velocityX: Double.random(in: speed),
                    velocityY: 0,
                    angle: angle,
                    color: colors.randomElement()!,
                    size: Double.random(in: particleSize),
                    lifetime: Double.random(in: lifetime),
                    shape: particleShape
                )
            }
            
            particles.append(particle)
        }
    }
    
    // MARK: - 清理过期粒子
    private func cleanupOldParticles() {
        let now = Date().timeIntervalSinceReferenceDate
        particles.removeAll { particle in
            now - particle.creationTime > particle.lifetime
        }
    }
}

// MARK: - 粒子形状枚举
enum ParticleShape {
    case circle
    case line(length: Double = 10) // 线条，可自定义长度倍数
    case square
    case star
    case heart
    case triangle
}

// MARK: - 发射方向枚举
enum EmissionDirection {
    case leftToRight
    case rightToLeft
    case bottomToTop
    case topToBottom
    case circular(center: CGPoint)
}

// MARK: - 粒子模型
struct Particle: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let velocityX: Double
    let velocityY: Double
    let angle: Double
    let color: Color
    let size: Double
    let lifetime: Double
    let creationTime: TimeInterval
    let shape: ParticleShape
    
    init(x: Double, y: Double, velocityX: Double, velocityY: Double,
         angle: Double, color: Color, size: Double, lifetime: Double, shape: ParticleShape) {
        self.x = x
        self.y = y
        self.velocityX = velocityX
        self.velocityY = velocityY
        self.angle = angle
        self.color = color
        self.size = size
        self.lifetime = lifetime
        self.creationTime = Date().timeIntervalSinceReferenceDate
        self.shape = shape
    }
}

// MARK: - 自定义形状
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let pointCount = 5
        
        for i in 0..<pointCount * 2 {
            let angle = (Double(i) * .pi / Double(pointCount)) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.25))
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control1: CGPoint(x: width * 0.1, y: height * 0.4),
            control2: CGPoint(x: width * 0.1, y: height * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.25),
            control1: CGPoint(x: width * 0.9, y: height * 0.8),
            control2: CGPoint(x: width * 0.9, y: height * 0.4)
        )
        return path
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - 预览示例
#Preview("圆形粒子") {
    ParticleEmitter()
        .background(.black)
}

#Preview("线条粒子") {
    ParticleEmitter(
        particleSize: 1...2,
        particleShape: .line(length: 10)
    )
    .background(.black)
}

#Preview("星星粒子") {
    ParticleEmitter(
        emissionRate: 0.1,
        particleCount: 2,
        speed: 30...80,
        particleSize: 3...6,
        colors: [.yellow, .orange, .white],
        particleShape: .star
    )
    .background(.black)
}

#Preview("爱心粒子") {
    ParticleEmitter(
        emissionRate: 0.15,
        particleCount: 1,
        speed: 20...60,
        particleSize: 4...8,
        colors: [.pink, .red],
        particleShape: .heart
    )
    .background(.black)
}

#Preview("混合形状") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            // 线条效果
            ParticleEmitter(
                particleSize: 1...3,
                colors: [.white, .gray],
                particleShape: .line(length: 20)
            )
            .frame(height: 50)
            
            // 星星效果
            ParticleEmitter(
                particleSize: 4...7,
                colors: [.yellow, .orange],
                particleShape: .star
            )
            .frame(height: 50)
            
            // 爱心效果
            ParticleEmitter(
                particleSize: 3...6,
                colors: [.pink, .red],
                particleShape: .heart
            )
            .frame(height: 50)
        }
    }
}
