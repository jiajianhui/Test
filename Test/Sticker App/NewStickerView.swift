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
                    CompletedView(image: viewModel.extractedSubject!, backgroundColor: viewModel.dominantColor)
                        .transition(.scale.combined(with: .opacity))
                }
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








#Preview {
    NewStickerView()
}
