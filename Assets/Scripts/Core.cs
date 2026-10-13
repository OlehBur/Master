

public static class Core {
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
