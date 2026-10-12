using Abp.Application.Navigation;
using Abp.Authorization;
using Abp.Localization;
using ToeicExam.Authorization;

namespace ToeicExam.Web.Startup;

/// <summary>
/// This class defines menus for the application.
/// </summary>
public class ToeicExamNavigationProvider : NavigationProvider
{
    public override void SetNavigation(INavigationProviderContext context)
    {
        context.Manager.MainMenu
            .AddItem(
                new MenuItemDefinition(
                    "Exams",
                    new FixedLocalizableString("Quản lý Đề thi TOEIC"),
                    url: "Exams",
                    icon: "fas fa-book-reader"
                )
            )
            .AddItem(
                new MenuItemDefinition(
                    "StudentTest",
                    new FixedLocalizableString("Giao diện Làm bài thi"),
                    url: "http://localhost:8080",
                    icon: "fas fa-pencil-alt"
                )
            )
            .AddItem(
                new MenuItemDefinition(
                    PageNames.About,
                    new FixedLocalizableString("Giới thiệu hệ thống"),
                    url: "About",
                    icon: "fas fa-info-circle"
                )
            );
    }

    private static ILocalizableString L(string name)
    {
        return new LocalizableString(name, ToeicExamConsts.LocalizationSourceName);
    }
}