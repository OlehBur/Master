using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(Rigidbody))]
public class SpaceshipController : MonoBehaviour {
    [Header("Movement")]
    [SerializeField] float mainThrust = 50f;
    [SerializeField] float strafeThrust = 30f;
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

    private Rigidbody rb;
    private float moveFwdInput;   // W/S
    private float keyYawInput;   // A/D rot arounf Y
    private float verticalInput;
    private Vector2 lookInput;   // mouse pitch ,yaw
    private bool isBoosting;     // l ctrl

    private float activeRoll;

    public float ForwardProgression { get; private set; }
    public float VerticalProgression { get; private set; }

    private void Awake() {
        rb = GetComponent<Rigidbody>();

        rb.useGravity = false;
        rb.linearDamping = linearDrag;
        rb.angularDamping = angularDrag;
    }

    private void OnEnable() {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void OnDisable() {
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }

    private void Update() {
        HandleInput();
        CalculateProgressions();
        Animations();
    }

    void Animations() {
        propellerL.Rotate(Vector3.up * VerticalProgression * propellersSpeed * Time.deltaTime);
        propellerR.Rotate(Vector3.up * VerticalProgression * propellersSpeed * Time.deltaTime);
        engineRotableL.Rotate(Vector3.right * ForwardProgression * rotablesSpeed * Time.deltaTime);
        engineRotableR.Rotate(Vector3.right * ForwardProgression * rotablesSpeed * Time.deltaTime);
        Debug.Log(ForwardProgression * rotablesSpeed + ", " + VerticalProgression * propellersSpeed);
    }

    private void FixedUpdate() {
        ApplyMovement();
        ApplyFullRotation();
    }

    void HandleInput() {
        if (Keyboard.current == null || Mouse.current == null)
            return;

        //  W / S fwd\bkwd
        moveFwdInput = 0f;
        if (Keyboard.current.wKey.isPressed)
            moveFwdInput += 1f;
        if (Keyboard.current.sKey.isPressed)
            moveFwdInput -= 1f;

        // rot around Y (A/D or <- \ ->)
        keyYawInput = 0f;
        if (Keyboard.current.dKey.isPressed || Keyboard.current.rightArrowKey.isPressed)
            keyYawInput += 1f;
        if (Keyboard.current.aKey.isPressed || Keyboard.current.leftArrowKey.isPressed)
            keyYawInput -= 1f;

        // up Space / down L Shift
        verticalInput = 0f;
        if (Keyboard.current.spaceKey.isPressed)
            verticalInput += 1f;
        if (Keyboard.current.leftShiftKey.isPressed)
            verticalInput -= 1f;

        // sprint L Ctrl
        isBoosting = Keyboard.current.leftCtrlKey.isPressed;

        // rot by mouse (Îñ³ X òà Y)
        lookInput = Mouse.current.delta.ReadValue() * mouseSensitivity;
    }

    //progressopms for anims
    private void CalculateProgressions() {
        // fwd \ bwd
        if (moveFwdInput > 0)
            ForwardProgression = isBoosting ?
                2f : 1f;
        else if (moveFwdInput < 0)
            ForwardProgression = -1f;
        else
            ForwardProgression = .5f;
        
        // up / down
        if (verticalInput > 0)
            VerticalProgression = isBoosting ?
                2f : 1f;
        else if (verticalInput < 0)
            VerticalProgression = -1f;
        else
            VerticalProgression = .5f;

        //Debug.Log(ForwardProgression + ", " + VerticalProgression);
    }

    // phys 
    private void ApplyMovement() {
        float boostMult = isBoosting ?
            2f : 1f;

        Vector3 forwardForce = transform.forward * moveFwdInput * mainThrust
            * (moveFwdInput > 0 ? boostMult : 1f);
        Vector3 upForce = transform.up * verticalInput * verticalThrust * (verticalInput > 0 ? boostMult : 1f);

        rb.AddForce(forwardForce + upForce, ForceMode.Acceleration);
    }

    // phys rot
    private void ApplyFullRotation() {
        // rot by mouse (Yaw + Pitch)
        float mouseYaw = lookInput.x * yawSpeed;
        float mousePitch = -lookInput.y * pitchSpeed;

        // rot around Y by A/D 
        float keyYaw = keyYawInput * keyYawSpeed;

        //  vis roll on rotation
        float targetRoll = (-lookInput.x * rollAmount) + (-keyYawInput * rollAmount);
        activeRoll = Mathf.Lerp(activeRoll, targetRoll, Time.fixedDeltaTime * rollSpeed);

        Vector3 totalYaw = transform.up * (mouseYaw + keyYaw);
        Vector3 totalPitch = transform.right * mousePitch;
        Vector3 totalRoll = transform.forward * activeRoll;

        Vector3 torque = totalYaw + totalPitch + totalRoll;
        rb.AddTorque(torque, ForceMode.Acceleration);
    }
}