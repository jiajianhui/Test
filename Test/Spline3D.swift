//
//  Spline3D.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/22.
//

import SplineRuntime
import SwiftUI

struct Spline3D: View {
    var body: some View {
        VStack {
            Spline()
                .frame(height: 600)
                .ignoresSafeArea(.all)
        }
    }
}

#Preview {
    Spline3D()
}



struct Spline: View {
    var body: some View {
        // fetching from cloud
        let url = URL(string: "https://build.spline.design/WvHM2QuYFtAWiaJsYMmQ/scene.splineswift")!

        // // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!

        try? SplineView(sceneFileURL: url)
    }
}
