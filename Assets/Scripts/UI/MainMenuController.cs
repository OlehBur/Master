using System;
using UnityEngine;
using UnityEngine.InputSystem;
using VContainer;


public enum ShaderType {
    None,
    Terrain,
    Ocean,
    Space
}

public interface IMenuWndService : IWndService {
    public void ToggleWnd();
}

public class MainMenuController : MonoBehaviour, IMenuWndService {
    [SerializeField] InputActionReference menuQAction;
    [SerializeField] InputActionReference settingsEAction;
    [SerializeField] GameObject mainMenu;
    //[SerializeField] ShaderSettingsController shaderSettingsController;

    [Inject] private readonly IShaderpassService _shaderService;
    //[Inject] private readonly IMenuWndService _menuWndService;
    [Inject] private readonly ISettingsWndService _settingsWndService;

    public bool IsOpen { get; private set; }
    public event Action<bool> OnStateChanged;


    public void ToggleWnd() {
        IsOpen = !IsOpen;
        OnStateChanged?.Invoke(IsOpen);
    }

    private void OnEnable() {
        menuQAction.action.Enable();
        menuQAction.action.performed += OnMenu;
        settingsEAction.action.Enable();
        settingsEAction.action.performed += OnSettings;
    }

    void OnDisable() {
        _shaderService.DisableAllPasses();
        menuQAction.action.performed -= OnMenu;
        menuQAction.action.Disable();
        settingsEAction.action.performed -= OnSettings;
        settingsEAction.action.Disable();
    }

    private void Start() {
        OnStateChanged += OnMenuStateChanged;
        OnMenuStateChanged(IsOpen);
    }

    void OnMenu(InputAction.CallbackContext ctx) {
        ToggleWnd();
    }

    void OnSettings(InputAction.CallbackContext ctx) {
        _settingsWndService.ToggleWnd(_shaderService.CurrentShader);
    }

    public void OnActivateTerrain() {
        _shaderService.ActivateShader(ShaderType.Terrain);
        ToggleWnd();
    }
    public void OnActivateOcean() {
        _shaderService.ActivateShader(ShaderType.Ocean);
        ToggleWnd();
    }
    public void OnActivateSpace() {
        _shaderService.ActivateShader(ShaderType.Space);
        ToggleWnd();
    }
    public void OnResetShaders() {
        _shaderService.DisableAllPasses();
        ToggleWnd();
    }

    private void OnMenuStateChanged(bool isOpen) => mainMenu.SetActive(isOpen);

}
