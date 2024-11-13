/*
 Shows how to convert raw vertex attribute data to an instance of MDLMesh.
 */
import Cocoa
import SceneKit
import SceneKit.ModelIO
import PlaygroundSupport

import ModelIO

struct Vertex {
    var x, y, z: Float
    var nx, ny, nz: Float
    var u, v: Float
    var red, green, blue, alpha: Float
}

let vertices: [Vertex] = [
    Vertex(x: 0.000000, y: 1.0, z: 0.0,
           nx: 0.0, ny: 0.0, nz: 1.0,
           u:  0.500000, v: 1.00,
           red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
    Vertex(x: -1.000000, y: -0.5, z: 0.0,
           nx: 0.0, ny: 0.0, nz: 1.0,
           u:  0.0, v: 0.0,
           red:0.0, green: 1.0, blue: 0.0, alpha: 1.0),
    Vertex(x: 1.000000, y: -0.5, z: 0.0,
           nx: 0.0, ny: 0.0, nz: 1.0,
           u:  1.0, v: 0.0,
           red:0.0, green: 0.0, blue: 1.0, alpha: 1.0),
]

let indices: [UInt16] = [
    0,  1,  2,
]

let allocator = MDLMeshBufferDataAllocator()

let vertexBuffer = allocator.newBuffer(MemoryLayout<Vertex>.stride * vertices.count,
                                       type: .vertex)

let indexBuffer = allocator.newBuffer(MemoryLayout<UInt16>.stride * indices.count,
                                      type: .index)

let vertexMap = vertexBuffer.map()
vertexMap.bytes.assumingMemoryBound(to: Vertex.self).assign(from: vertices,
                                                            count: vertices.count)

let indexMap = indexBuffer.map()
indexMap.bytes.assumingMemoryBound(to: UInt16.self).assign(from: indices,
                                                           count: indices.count)

// First instantiate the MDLSubMesh which contains the Indices data.
let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                         indexCount: indices.count,
                         indexType: .uInt16,
                         geometryType: .triangles,
                         material: nil)

// Specify the layout of the interleaved verter attribute data
let vertexDescriptor = MDLVertexDescriptor()
vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                    format: .float3,
                                                    offset: 0,
                                                    bufferIndex: 0)

vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                    format: .float3,
                                                    offset: MemoryLayout<Float>.stride * 3,
                                                    bufferIndex: 0)

vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                    format: .float2,
                                                    offset: MemoryLayout<Float>.stride * 6,
                                                    bufferIndex: 0)
vertexDescriptor.attributes[3] = MDLVertexAttribute(name: MDLVertexAttributeColor,
                                                    format: .float4,
                                                    offset: MemoryLayout<Float>.stride * 8,
                                                    bufferIndex: 0)
vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.stride * 12)

// Now, instantiate the MDLMesh which contains the Vertex data
let mdlMesh = MDLMesh(vertexBuffer: vertexBuffer,
                      vertexCount: vertices.count,
                      descriptor: vertexDescriptor,
                      submeshes: [submesh])

// We use SceneKit to render the instantiated mesh.
let triangleNode = SCNNode(mdlObject: mdlMesh)
let frameRect = NSRect(x: 0, y: 0,
                       width: 320, height: 320)
let sceneView = SCNView(frame: frameRect)
let scene = SCNScene()
sceneView.scene = scene
scene.rootNode.addChildNode(triangleNode)
sceneView.backgroundColor = NSColor.gray
sceneView.autoenablesDefaultLighting = true
sceneView.allowsCameraControl = true

PlaygroundPage.current.liveView = sceneView

