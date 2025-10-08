//
//  DotGridBackground.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/8.
//

import SwiftUI

struct DotGridBackground: View {
    var dotSize: CGFloat = 3
    var spacing: CGFloat = 28
    var dotColor: Color = .gray.opacity(0.25)
    var background: Color = .clear

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / spacing)
            let rows = Int(size.height / spacing)

            // 计算偏移量，让网格居中
            let offsetX = (size.width - CGFloat(columns) * spacing) / 2
            let offsetY = (size.height - CGFloat(rows) * spacing) / 2

            for row in 0...rows {
                for column in 0...columns {
                    let x = CGFloat(column) * spacing + offsetX
                    let y = CGFloat(row) * spacing + offsetY

                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )

                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                }
            }
        }
        .background(background)
        .ignoresSafeArea()
    }
}

#Preview {
    DotGridBackground(dotSize: 4, spacing: 30, dotColor: .gray.opacity(0.3))
}

