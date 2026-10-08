using Unity.VisualScripting;
using UnityEngine;
using VContainer;


public class EngineController : MonoBehaviour {
    //[SerializeField] ParticleSystem fireParticle;
    [SerializeField] ParticleSystem bubbleParticle;

    [Inject] private readonly IShaderService _shaderService;

    //void Start()
    //{
    //if(MainManager.Instance != null) 
    //MainManager.Instance.OnShaderChanged+=
    //}

    void Update() {
        if (_shaderService.CurrentShader == ShaderType.Ocean) {
            bool isOverOcean = transform.position.y > _shaderService.GetOceanLevel();

            //fireParticle.gameObject.SetActive(isOverOcean);
            bubbleParticle.gameObject.SetActive(!isOverOcean);
        }
        else {
            //fireParticle.gameObject.SetActive(true);
            bubbleParticle.gameObject.SetActive(false);
        }
    }

    //public void set(float value) {
    //    if (oceanMaterial != null) {
    //        oceanMaterial.SetFloat(OceanLevelID, value);
    //    }
    //}
}
