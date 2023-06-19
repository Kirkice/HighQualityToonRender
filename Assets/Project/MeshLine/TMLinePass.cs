using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public class TMLinePass : ScriptableRenderPass
{
    static readonly string k_RenderTag = "TM Line";

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
    }
    
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var cmd = CommandBufferPool.Get(k_RenderTag);
        Render(cmd, ref renderingData);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var camera = renderingData.cameraData.camera;
        if (camera.name == "Preview Scene Camera") {
            return;
        }
        foreach (var Item in TMLineRenderer.Collection.Keys) {
            Item.Draw(cmd);
        }
    }
}
