using UnityEngine;
using VContainer;


public class EngineController : MonoBehaviour {
    //[SerializeField] GameObject fireParticle;
    [SerializeField] GameObject bubbleParticle;

    [Inject] private readonly IShaderpassService _shaderService;

    //void Start() {
    //    _shaderService.OnShaderChanged += ChangeParticles;
    //}

    //void ChangeParticles(ShaderType type) {
    //    if (type == ShaderType.Ocean) {
    //        bool isOverOcean = transform.position.y > _shaderService.GetOceanLevel();

    //        //fireParticle.SetActive(isOverOcean);
    //        bubbleParticle.SetActive(!isOverOcean);
    //    }
    //    else {
    //        //fireParticle.SetActive(true);
    //        bubbleParticle.SetActive(false);
    //    }
    //}

    private void Update() {
        if (_shaderService.CurrentShader == ShaderType.Ocean) {
            bool isOverOcean = transform.position.y > _shaderService.GetOceanLevel();

            //fireParticle.SetActive(isOverOcean);
            bubbleParticle.SetActive(!isOverOcean);
        }
        else {
            //fireParticle.SetActive(true);
            bubbleParticle.SetActive(false);
        }
    }
}
