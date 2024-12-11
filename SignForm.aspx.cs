using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using iTextSharp.text.pdf;
using iTextSharp.text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using iTextSharp.text.pdf.parser;
using System.Diagnostics;
namespace SigningFormGenerator
{
    public partial class SignForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

                if (Request.Params["guid"] != null)
                {

                    ProcessID.Value = Request.Params["guid"].ToString();

                    GetPdfUrl(Request.Params["guid"].ToString());

                }
            }

            //Session["ViewPdfUrl"] = "UploadedFiles/b.pdf";

        }

        public void GetPdfUrl(string guid)
        {
            string pdfurl = "";
            string sql = @"SELECT tbl_TemplateSigning.TID, tbl_TemplateList.PdfUrl, tbl_TemplateList.CompanyID 
                        FROM tbl_TemplateList INNER JOIN
                                     tbl_TemplateSigning ON tbl_TemplateList.ID = tbl_TemplateSigning.TID
                        WHERE(tbl_TemplateSigning.ID = N'" + guid + "')";
            Database db = new Database();
            DataTable dt = new DataTable();
            db.Execute(sql, out dt);
            if (dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];
                TemplateID.Value = dr["TID"].ToString();
                pdfUrl.Value = dr["PdfUrl"].ToString();

            }

        }
        [WebMethod]
        public static List<FieldData> GetSavedFields(string ProcessID, string TID)
        {
            List<FieldData> savedFields = new List<FieldData>();
            string connectionString = ConfigurationManager.AppSettings["ConnString"].ToString();

            Database db = new Database();
            DataTable dt = new DataTable();
            string sql = @"SELECT tsd.IsEditable,td.PageNumber, tsd.TSID, tsd.TID, tsd.Value, tsd.FieldID, td.PageNumber, td.FieldType, td.LeftPosition, td.TopPosition
                            FROM tbl_TemplateDetails as td INNER JOIN
                            tbl_TemplateSigningDetails as tsd ON td.TID = tsd.TID AND td.fieldID = tsd.FieldID WHERE tsd.TID = '" + TID + "' and tsd.TSID = '" + ProcessID + "'";
            db.Execute(sql, out dt);
            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    FieldData field = new FieldData();
                    field.ID = dr["fieldID"].ToString();
                    field.FieldType = dr["FieldType"].ToString();
                    field.LeftPosition = Convert.ToDouble(dr["LeftPosition"].ToString());
                    field.TopPosition = Convert.ToDouble(dr["TopPosition"].ToString());
                    field.Value = dr["Value"].ToString();
                    field.IsEditable = Convert.ToBoolean(dr["IsEditable"].ToString());
                    field.PageNumber = Convert.ToInt32(dr["PageNumber"].ToString());

                    savedFields.Add(field);
                }
            }
            HttpContext.Current.Session["ProcessID"] = ProcessID;
            return savedFields;

        }

        [WebMethod]
        public static void UpdateFields(SigingList siging, string pdfUrl)
        {
            
            List<FieldData> fields = siging.fieldDatas;
            string connectionString = ConfigurationManager.AppSettings["ConnString"].ToString();
            Database db = new Database();
            DateTime currentDate = DateTime.Now.Date;

            string query = " UPDATE tbl_TemplateSigning  SET  SignedDate = '" + currentDate + "' WHERE   TID = '" + siging.TID + "'and ID = '" + siging.SID + "';";
       
            foreach (var field in fields)
            {


                string value = field.Value;
                if (field.FieldType == "signature")
                {
                    value = SaveSignatureImage(value);

                }


                query += " UPDATE tbl_TemplateSigningDetails SET  Value = '" + value + "' WHERE fieldID = '" + field.ID + "' and TID = '" + siging.TID + "'and TSID = '" + siging.SID + "';";
                 
            }
            try
            {
                db.Open();
                db.Execute(query);
                db.Close();

            }
            catch(Exception ex)
            {
                EmailProcessor.Log(ex.Message);

            }


            //string savedpdfUrl=GenerateAndSavePdf(pdfUrl, siging.SID, siging.TID);
            //SendEmail(siging.SID, savedpdfUrl);
        }

        public static string SaveSignatureImage(string imageData)
        {
            try
            {
                
                byte[] imageBytes = Convert.FromBase64String(imageData.Split(',')[1]);
               
                string fileName = Guid.NewGuid().ToString() + ".png";
                string filePath = HttpContext.Current.Server.MapPath("~/SignedFiles/SignedImage/") + fileName;

              
                File.WriteAllBytes(filePath, imageBytes);

               
                return "~/SignedFiles/SignedImage/" + fileName;
            }
            catch (Exception ex)
            {
                EmailProcessor.Log(ex.Message);
               
                return null;
            }
        }
    

         //pdf generating with itextsarp
        private static string GenerateAndSavePdf(string pdfurl,string processid,string TID)
        {
            List<FieldData> fieldData = GetSavedFields(processid, TID);
            string pdfTemplatePath = System.Web.HttpContext.Current.Server.MapPath(pdfurl);
             
            string outputPdfPath = System.Web.HttpContext.Current.Server.MapPath("~/SignedFiles/" + processid + ".pdf");

            using (FileStream fs = new FileStream(outputPdfPath, FileMode.Create))
            {
                PdfReader pdfReader = new PdfReader(pdfTemplatePath);
                PdfStamper pdfStamper = new PdfStamper(pdfReader, fs);

                foreach (var field in fieldData)
                {
                    PdfContentByte pdfPage = pdfStamper.GetOverContent(field.PageNumber);
                    if (field.FieldType == "TextBox")
                    {
                        ColumnText.ShowTextAligned(pdfPage, Element.ALIGN_LEFT, new Phrase(field.Value),
                            (float)ConvertPercentageToAbsolute(field.LeftPosition, pdfPage.PdfDocument.PageSize.Width),
                            (float)ConvertPercentageToAbsolute(100 - field.TopPosition, pdfPage.PdfDocument.PageSize.Height), 0);
                    }
                    else if (field.FieldType == "signature")
                    {
                        Image signatureImage = Image.GetInstance(new Uri(HttpContext.Current.Server.MapPath(field.Value)));
                        signatureImage.SetAbsolutePosition(
                            (float)ConvertPercentageToAbsolute(field.LeftPosition, pdfPage.PdfDocument.PageSize.Width),
                            (float)ConvertPercentageToAbsolute(100 - field.TopPosition, pdfPage.PdfDocument.PageSize.Height) - signatureImage.ScaledHeight);
                        pdfPage.AddImage(signatureImage);
                    }
                }

                pdfStamper.FormFlattening = true;
                pdfStamper.Close();
                pdfReader.Close();
            }

            string pdfUrl = "~/SignedFiles/" + processid + ".pdf";  
            return pdfUrl;
        }

        private static double ConvertPercentageToAbsolute(double percentage, double total)
        {
            return (percentage / 100) * total;
        }
    }
}