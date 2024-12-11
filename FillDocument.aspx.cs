using iTextSharp.text.pdf;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class FillDocument : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load the uploaded PDF URL
                string pdfUrl = Session["UploadedPdfUrl"] as string;
                if (string.IsNullOrEmpty(pdfUrl))
                {
                    Response.Redirect("Upload.aspx");
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            string pdfUrl = Server.MapPath("~/UploadedFiles/") + Path.GetFileName(Session["UploadedPdfUrl"] as string);
            string filledPdfPath = Server.MapPath("~/UploadedFiles/Filled_") + Path.GetFileName(Session["UploadedPdfUrl"] as string);

            using (var reader = new PdfReader(pdfUrl))
            using (var fs = new FileStream(filledPdfPath, FileMode.Create, FileAccess.Write))
            using (var stamper = new PdfStamper(reader, fs))
            {
                AcroFields fields = stamper.AcroFields;

                foreach (string key in Request.Form.AllKeys)
                {
                    if (key.StartsWith("field_"))
                    {
                        string fieldName = key.Substring("field_".Length);
                        string fieldValue = Request.Form[key];
                        fields.SetField(fieldName, fieldValue);
                    }
                }

                stamper.FormFlattening = true;
            }

            Response.Redirect("UploadedFiles/Filled_" + Path.GetFileName(Session["UploadedPdfUrl"] as string));
        }
    }
}