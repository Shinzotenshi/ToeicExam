using ToeicExam.Debugging;

namespace ToeicExam;

public class ToeicExamConsts
{
    public const string LocalizationSourceName = "ToeicExam";

    public const string ConnectionStringName = "Default";

    public const bool MultiTenancyEnabled = true;


    /// <summary>
    /// Default pass phrase for SimpleStringCipher decrypt/encrypt operations
    /// </summary>
    public static readonly string DefaultPassPhrase =
        DebugHelper.IsDebug ? "gsKxGZ012HLL3MI5" : "24c40aa7c727458fbf8519d1f0da8eb2";
}
