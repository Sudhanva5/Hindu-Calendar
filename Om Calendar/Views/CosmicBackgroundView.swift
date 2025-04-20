import SwiftUI
import MetalKit

struct CosmicBackgroundView: View {
    @State private var metalView = MTKView()
    @State private var renderer: CosmicRenderer?
    
    var body: some View {
        GeometryReader { geometry in
            MetalViewRepresentable(metalView: $metalView, renderer: $renderer)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    setupMetal()
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        metalView.device = device
        metalView.framebufferOnly = true
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = false
        metalView.autoResizeDrawable = true
        metalView.contentMode = .scaleToFill
        
        renderer = CosmicRenderer(metalView: metalView, device: device)
    }
}

struct MetalViewRepresentable: UIViewRepresentable {
    @Binding var metalView: MTKView
    @Binding var renderer: CosmicRenderer?
    
    func makeUIView(context: Context) -> MTKView {
        metalView.contentMode = .scaleToFill
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update if needed
    }
}

class CosmicRenderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?
    private var startTime: Date
    
    init(metalView: MTKView, device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.startTime = Date()
        
        super.init()
        
        metalView.delegate = self
        metalView.preferredFramesPerSecond = 60
        metalView.contentMode = .scaleToFill
        
        createPipelineState(metalView: metalView)
        createBuffers()
    }
    
    private func createPipelineState(metalView: MTKView) {
        guard let library = device.makeDefaultLibrary() else { return }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "cosmic_vertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "cosmic_fragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }
    
    private func createBuffers() {
        // Create uniform buffer
        var uniforms = Uniforms(resolution: SIMD2<Float>(0, 0), time: 0)
        uniformBuffer = device.makeBuffer(bytes: &uniforms,
                                        length: MemoryLayout<Uniforms>.stride,
                                        options: [])
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let uniformBuffer = uniformBuffer else { return }
        var uniforms = Uniforms(
            resolution: SIMD2<Float>(Float(size.width), Float(size.height)),
            time: 0
        )
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<Uniforms>.stride)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        // Update time uniform
        let elapsed = Float(-startTime.timeIntervalSinceNow)
        var uniforms = Uniforms(
            resolution: SIMD2<Float>(Float(view.drawableSize.width),
                                   Float(view.drawableSize.height)),
            time: elapsed
        )
        uniformBuffer?.contents().copyMemory(from: &uniforms,
                                           byteCount: MemoryLayout<Uniforms>.stride)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangleStrip,
                                     vertexStart: 0,
                                     vertexCount: 4)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

// MARK: - Supporting Types

struct Uniforms {
    var resolution: SIMD2<Float>
    var time: Float
}

#Preview {
    CosmicBackgroundView()
} 
