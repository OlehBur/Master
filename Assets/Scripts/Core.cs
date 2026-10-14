using System;

public interface IWndService {
    bool IsOpen { get; }
    event Action<bool> OnStateChanged;
}


public static class Core {
    public static readonly string SHADER_PROPERTIE_HEADER_NAME = "_Header_";


    public static string GetDecimalFormat(float number) {
        if (number < 1)
            return "F4";
        else if (number >= 10)
            return "F2";
        else if (number >= 100)
            return "F1";
        else
            return "F3";
    }
}
