using Abp.AspNetCore.Mvc.Authorization;
using ToeicExam.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace ToeicExam.Web.Controllers;

public class HomeController : ToeicExamControllerBase
{
    public ActionResult Index()
    {
        return RedirectToAction("Index", "Exams");
    }
}
