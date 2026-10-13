using UnityEngine;
using UnityEngine.InputSystem;
using VContainer;


[RequireComponent(typeof(Rigidbody))]
public class SpaceshipController : MonoBehaviour {
    [Header("Movement")]
    [SerializeField] float mainThrust = 50f;
    //[SerializeField] float strafeThrust = 30f;
    [SerializeField] float verticalThrust = 30f;

    [Header("Rot")]
    [SerializeField] float mouseSensitivity = 0.1f;
    [SerializeField] float pitchSpeed = 3f;         // mouse Y 
    [SerializeField] float yawSpeed = 1f;           // mouse X
    [SerializeField] float keyYawSpeed = 10f;
    [SerializeField] float rollAmount = 55f;
    [SerializeField] float rollSpeed = 1f;

    [Header("Damp phys")]//resistances
    [SerializeField] float linearDrag = 200f;
    [SerializeField] float angularDrag = 40f;

    [Header("Anim Transforms")]
    [SerializeField] float propellersSpeed = 10f;
    [SerializeField] float rotablesSpeed = 2f;
    [SerializeField] Transform propellerL;
    [SerializeField] Transform propellerR;
    [SerializeField] Transform engineRotableL;
    [SerializeField] Transform engineRotableR;

    [Inject] private readonly MenuService _menuService;

    private Rigidbody _rb;
    private float _moveFwdInput;   // W/S
    private float _keyYawInput;   // A/D rot arounf Y
    private float _verticalInput;
    private Vector2 _lookInput;   // mouse pitch ,yaw
    private bool _isBoosting;     // l ctrl
    private float _activeRoll;

    public float ForwardProgression { get; private set; }
    public float VerticalProgression { get; private set; }

    private void Awake() {
        _rb = GetComponent<Rigidbody>();

        _rb.useGravity = false;
        _rb.linearDamping = linearDrag;
        _rb.angularDamping = angularDrag;
    }

    private void Start() {
        _menuService.OnStateChanged += ChangeControlActivation;
        ChangeControlActivation(_menuService.IsOpen);
    }

    private void Update() {
        if (!_menuService.IsOpen)
            HandleInput();

        CalculateProgressions();
        Animations();
    }

    void ChangeControlActivation(bool isActive) {
        if (isActive) {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
        else {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    void Animations() {
        propellerL.Rotate(Vector3.up * VerticalProgression * propellersSpeed * Time.deltaTime);
        propellerR.Rotate(Vector3.up * VerticalProgression * propellersSpeed * Time.deltaTime);
        engineRotableL.Rotate(Vector3.right * ForwardProgression * rotablesSpeed * Time.deltaTime);
        engineRotableR.Rotate(Vector3.right * ForwardProgression * rotablesSpeed * Time.deltaTime);
        //Debug.Log(ForwardProgression * rotablesSpeed + ", " + VerticalProgression * propellersSpeed);
    }

    private void FixedUpdate() {
        ApplyMovement();
        ApplyFullRotation();
    }

    void HandleInput() {
        if (Keyboard.current == null || Mouse.current == null)
            return;

        //  W / S fwd\bkwd
        _moveFwdInput = 0f;
        if (Keyboard.current.wKey.isPressed)
            _moveFwdInput += 1f;
        if (Keyboard.current.sKey.isPressed)
            _moveFwdInput -= 1f;

        // rot around Y (A/D or <- \ ->)
        _keyYawInput = 0f;
        if (Keyboard.current.dKey.isPressed || Keyboard.current.rightArrowKey.isPressed)
            _keyYawInput += 1f;
        if (Keyboard.current.aKey.isPressed || Keyboard.current.leftArrowKey.isPressed)
            _keyYawInput -= 1f;

        // up Space / down L Shift
        _verticalInput = 0f;
        if (Keyboard.current.spaceKey.isPressed)
            _verticalInput += 1f;
        if (Keyboard.current.leftShiftKey.isPressed)
            _verticalInput -= 1f;

        // sprint L Ctrl
        _isBoosting = Keyboard.current.leftCtrlKey.isPressed;

        // rot by mouse (Îñ³ X òà Y)
        _lookInput = Mouse.current.delta.ReadValue() * mouseSensitivity;
    }

    //progressopms for anims
    private void CalculateProgressions() {
        // fwd \ bwd
        if (_moveFwdInput > 0)
            ForwardProgression = _isBoosting ?
                2f : 1f;
        else if (_moveFwdInput < 0)
            ForwardProgression = -1f;
        else
            ForwardProgression = .5f;

        // up / down
        if (_verticalInput > 0)
            VerticalProgression = _isBoosting ?
                2f : 1f;
        else if (_verticalInput < 0)
            VerticalProgression = -1f;
        else
            VerticalProgression = .5f;

        //Debug.Log(ForwardProgression + ", " + VerticalProgression);
    }

    // phys 
    private void ApplyMovement() {
        float boostMult = _isBoosting ?
            2f : 1f;

        Vector3 forwardForce = transform.forward * _moveFwdInput * mainThrust
            * (_moveFwdInput > 0 ? boostMult : 1f);
        Vector3 upForce = transform.up * _verticalInput * verticalThrust * (_verticalInput > 0 ? boostMult : 1f);

        _rb.AddForce(forwardForce + upForce, ForceMode.Acceleration);
    }

    // phys rot
    private void ApplyFullRotation() {
        // rot by mouse (Yaw + Pitch)
        float mouseYaw = _lookInput.x * yawSpeed;
        float mousePitch = -_lookInput.y * pitchSpeed;

        // rot around Y by A/D 
        float keyYaw = _keyYawInput * keyYawSpeed;

        //  vis roll on rotation
        float targetRoll = (-_lookInput.x * rollAmount) + (-_keyYawInput * rollAmount);
        _activeRoll = Mathf.Lerp(_activeRoll, targetRoll, Time.fixedDeltaTime * rollSpeed);

        Vector3 totalYaw = transform.up * (mouseYaw + keyYaw);
        Vector3 totalPitch = transform.right * mousePitch;
        Vector3 totalRoll = transform.forward * _activeRoll;

        Vector3 torque = totalYaw + totalPitch + totalRoll;
        _rb.AddTorque(torque, ForceMode.Acceleration);
    }
}