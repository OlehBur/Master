
using System;

public class MenuService {
    public bool IsOpen { get; private set; } = true;
    public event Action<bool> OnStateChanged;

    public void Toggle() {
        IsOpen = !IsOpen;
        OnStateChanged?.Invoke(IsOpen);
    }
}