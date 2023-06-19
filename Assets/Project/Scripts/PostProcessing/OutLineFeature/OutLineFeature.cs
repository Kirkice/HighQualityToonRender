using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutLineFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Setting
    {
        public float BlurRadius = 1;
        public int downSample = 1;
        public int iteration = 1;
        
        public LayerMask renderLayer;
        [Range(1000, 5000)] public int queueMin = 2000;
        [Range(1000, 5000)] public int queueMax = 3000;
    }
    
    public Setting setting = new Setting();
    
    private OutLinePass m_OutLinePass;
    public override void Create()
    {
        m_OutLinePass = new OutLinePass(setting);
        m_OutLinePass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var dest =  RenderTargetHandle.CameraTarget;
        m_OutLinePass.Setup(renderer.cameraColorTarget, dest);
        renderer.EnqueuePass(m_OutLinePass);
    }
}
