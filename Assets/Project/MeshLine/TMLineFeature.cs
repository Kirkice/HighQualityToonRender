using UnityEngine.Rendering.Universal;
public class TMLineFeature : ScriptableRendererFeature
{
    TMLinePass m_TMLinePass;
    
    /// <inheritdoc/>
    public override void Create()
    {
        m_TMLinePass = new TMLinePass();
        m_TMLinePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var dest =  RenderTargetHandle.CameraTarget;
        renderer.EnqueuePass(m_TMLinePass);
    }
}
