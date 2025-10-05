import SwiftUI
import PhotosUI
import Vision
import CoreImage

// MARK: - 主视图
struct NewStickerView: View {
    
    @StateObject private var viewModel = StickerViewModel()
    
    var body: some View {
        ZStack {
            // 背景（根据状态变化）
            BackgroundView(state: viewModel.currentState)
            
            // 主要内容层
            ZStack {
                // 【阶段1】初始状态 - 欢迎界面
                if viewModel.currentState == .initial {
                    InitialView()
                        .transition(.opacity)
                }
                
                // 【阶段2】图片全屏显示 + 识别中
                if viewModel.currentState == .analyzing {
                    AnalyzingView(image: viewModel.capturedImage!)
                        .transition(.opacity)
                }
                
                // 【阶段3】主体跳出动画
                if viewModel.currentState == .extracting {
                    ExtractingView(
                        originalImage: viewModel.capturedImage!,
                        extractedImage: viewModel.extractedSubject!
                    )
                    .transition(.opacity)
                }
                
                // 【阶段4】最终卡片展示
                if viewModel.currentState == .completed {
                    CompletedView(image: viewModel.extractedSubject!)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // 顶部关闭按钮（始终显示）
            VStack {
                HStack {
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            // 底部操作按钮
            VStack {
                Spacer()
                BottomButtonsView(
                    state: viewModel.currentState,
                    onSelectPhoto: { viewModel.showPhotoPicker = true },
                    onRetake: { viewModel.reset() },
                    onSave: { viewModel.saveSticker() }
                )
            }
        }
        .photosPicker(
            isPresented: $viewModel.showPhotoPicker,
            selection: $viewModel.selectedPhoto,
            matching: .images
        )
        .alert("保存成功 ✅", isPresented: $viewModel.showSaveAlert) {
            Button("确定", role: .cancel) { }
        }
        .ignoresSafeArea()
    }
}




// MARK: - 邮票边框形状
struct StampBorderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchSize: CGFloat = 10
        let notchSpacing: CGFloat = 15
        
        // 绘制四边的齿孔
        // 顶边
        var x: CGFloat = 0
        while x < rect.width {
            path.addArc(
                center: CGPoint(x: x + notchSize/2, y: 0),
                radius: notchSize/2,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            x += notchSpacing
        }
        
        // 右边
        var y: CGFloat = 0
        while y < rect.height {
            path.addArc(
                center: CGPoint(x: rect.width, y: y + notchSize/2),
                radius: notchSize/2,
                startAngle: .degrees(270),
                endAngle: .degrees(90),
                clockwise: false
            )
            y += notchSpacing
        }
        
        // 底边
        x = rect.width
        while x > 0 {
            path.addArc(
                center: CGPoint(x: x - notchSize/2, y: rect.height),
                radius: notchSize/2,
                startAngle: .degrees(0),
                endAngle: .degrees(180),
                clockwise: false
            )
            x -= notchSpacing
        }
        
        // 左边
        y = rect.height
        while y > 0 {
            path.addArc(
                center: CGPoint(x: 0, y: y - notchSize/2),
                radius: notchSize/2,
                startAngle: .degrees(90),
                endAngle: .degrees(270),
                clockwise: false
            )
            y -= notchSpacing
        }
        
        return path
    }
}



// MARK: - 处理状态枚举
enum ProcessingState {
    case initial      // 初始状态
    case analyzing    // 识别中（全屏显示原图）
    case extracting   // 主体跳出动画
    case completed    // 完成（显示卡片）
}


