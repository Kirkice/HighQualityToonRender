using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutLinePass : ScriptableRenderPass
{
    const string m_ProfilerTag = "OutLine Pass";
    private Material material_blur;
    private Material material_pre;
    public int DownSampleNum = 1;
    public float BlurSpreadSize = 1.0f;
    public int BlurIterations = 1;

    RenderTexture m_OutLineRT;
    private RenderTargetHandle destination { get; set; }
    RenderTargetIdentifier currentTarget;
    RenderTargetHandle m_temporaryColorTexture;

    FilteringSettings filtering;
    
    public OutLinePass(OutLineFeature.Setting setting)
    {
        material_blur = new Material(Shader.Find("Hidden/Blur"));
        material_pre = new Material(Shader.Find("Hidden/OutLinePre"));
        
        this.BlurSpreadSize = setting.BlurRadius;
        this.DownSampleNum = setting.downSample;
        this.BlurIterations = setting.iteration;
        
        RenderQueueRange queue = new RenderQueueRange();
        queue.lowerBound = Mathf.Min(setting.queueMax, setting.queueMin);
        queue.upperBound = Mathf.Max(setting.queueMax, setting.queueMin);
        filtering = new FilteringSettings(queue, setting.renderLayer);
        
        m_temporaryColorTexture.Init("temporaryColorTexture");
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        m_OutLineRT = RenderTexture.GetTemporary(Screen.width, Screen.height,1,RenderTextureFormat.Default);
        m_OutLineRT.name = "_OutLineRT";
        ConfigureTarget(new RenderTargetIdentifier(m_OutLineRT));
        ConfigureClear(ClearFlag.All, Color.white);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
        if (renderingData.cameraData.cameraType != CameraType.Game)
            return;

        var draw2 = CreateDrawingSettings(new ShaderTagId("OutLine"), ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
        context.DrawRenderers(renderingData.cullResults, ref draw2, ref filtering);
        
        Render(cmd, ref renderingData);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var source = currentTarget;

        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
        opaqueDesc.depthBufferBits = 0;
        
        cmd.GetTemporaryRT(m_temporaryColorTexture.id, opaqueDesc) ;
        Blit(cmd, source, m_temporaryColorTexture.Identifier(), material_pre);
        

        int width = (int) (renderingData.cameraData.camera.pixelWidth);
        int height = (int) (renderingData.cameraData.camera.pixelHeight);
        RenderTexture src =
            RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.DefaultHDR);
        Blit(cmd, source, src);
        float widthMod = 1.0f / (1.0f * (1 << DownSampleNum));
        material_blur.SetFloat("_DownSampleValue", BlurSpreadSize * widthMod);
        int renderWidth = width >> DownSampleNum;
        int renderHeight = height >> DownSampleNum;

        RenderTexture renderBuffer =
            RenderTexture.GetTemporary(renderWidth, renderHeight, 0, RenderTextureFormat.Default);
        renderBuffer.filterMode = FilterMode.Bilinear;
        cmd.Blit(m_temporaryColorTexture.Identifier(), renderBuffer, material_blur, 0);

        for (int i = 0; i < BlurIterations; i++)
        {
            float iterationOffs = (i * 1.0f);
            material_blur.SetFloat("_DownSampleValue", BlurSpreadSize * widthMod + iterationOffs);
            RenderTexture tempBuffer =
                RenderTexture.GetTemporary(renderWidth, renderHeight, 0, RenderTextureFormat.Default);
            cmd.Blit(renderBuffer, tempBuffer, material_blur, 1);
            RenderTexture.ReleaseTemporary(renderBuffer);
            renderBuffer = tempBuffer;
            tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, RenderTextureFormat.Default);
            cmd.Blit(renderBuffer, tempBuffer, material_blur, 2);
            RenderTexture.ReleaseTemporary(renderBuffer);
            renderBuffer = tempBuffer;
        }
        material_blur.SetTexture("_Source",renderBuffer);
        material_blur.SetTexture("_SourceColor",src);
        material_blur.SetTexture("_OutLineColor",m_OutLineRT);
        Blit(cmd, m_temporaryColorTexture.Identifier(), source, material_blur,3);
        RenderTexture.ReleaseTemporary(renderBuffer);
        RenderTexture.ReleaseTemporary(src);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        if (destination == RenderTargetHandle.CameraTarget)
            cmd.ReleaseTemporaryRT(m_temporaryColorTexture.id);
        
        if (m_OutLineRT)
        {
            RenderTexture.ReleaseTemporary(m_OutLineRT);
            m_OutLineRT = null;
        }
    }

    public void Setup(in RenderTargetIdentifier currentTarget, RenderTargetHandle dest)
    {
        this.destination = dest;
        this.currentTarget = currentTarget;
    }
}