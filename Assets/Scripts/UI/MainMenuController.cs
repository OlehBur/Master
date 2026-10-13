using UnityEngine;
using UnityEngine.InputSystem;
using VContainer;


public enum ShaderType {
    None,
    Terrain,
    Ocean,
    Space
}

public class MainMenuController : MonoBehaviour {
    [SerializeField] InputActionReference escapeAction;
    [SerializeField] GameObject mainMenu;

    [Inject] private readonly IShaderpassService _shaderService;
    [Inject] private readonly MenuService _menuService;
    [Inject] private readonly ShaderReadPropertiesService _shaderReaderService;


    private void OnEnable() {
        escapeAction.action.Enable();
        escapeAction.action.performed += OnMenu;
    }

    void OnDisable() {
        _shaderService.DisableAllPasses();
        escapeAction.action.performed -= OnMenu;
        escapeAction.action.Disable();
    }

    private void Start() {
        _menuService.OnStateChanged += OnMenuStateChanged;
        OnMenuStateChanged(_menuService.IsOpen);
        //_shaderReaderService.InspectShaderProperties(ShaderType.Terrain);
    }

    void OnMenu(InputAction.CallbackContext ctx) {
        _menuService.Toggle();
    }

    public void OnActivateTerrain() {
        _shaderService.ActivateShader(ShaderType.Terrain);
        _menuService.Toggle();
    }
    public void OnActivateOcean() {
        _shaderService.ActivateShader(ShaderType.Ocean);
        _menuService.Toggle();
    }
    public void OnActivateSpace() {
        _shaderService.ActivateShader(ShaderType.Space);
        _menuService.Toggle();
    }
    public void OnResetShaders() {
        _shaderService.DisableAllPasses();
        _menuService.Toggle();
    }

    private void OnMenuStateChanged(bool isOpen) => mainMenu.SetActive(isOpen);

}
