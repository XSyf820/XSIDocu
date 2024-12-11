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
            // Open the connection outside the loop for better performance
            foreach (var field in fields)
            {


                string value = field.Value;
                if (field.FieldType == "signature")
                {
                    value = SaveSignatureImage(value);

                }


                query += " UPDATE tbl_TemplateSigningDetails SET  Value = '" + value + "' WHERE fieldID = '" + field.ID + "' and TID = '" + siging.TID + "'and TSID = '" + siging.SID + "';";
                 
            }
           
            db.Open();
            db.Execute(query);
            db.Close();

            string savedpdfUrl=GenerateAndSavePdf(pdfUrl, siging.SID, siging.TID);
            SendEmail(siging.SID, savedpdfUrl);

            
        }

        public static string SaveSignatureImage(string imageData)
        {
            try
            {
                // Convert base64 string to byte array
                byte[] imageBytes = Convert.FromBase64String(imageData.Split(',')[1]);
                // Define the path to save the image
                string fileName = Guid.NewGuid().ToString() + ".png";
                string filePath = HttpContext.Current.Server.MapPath("~/SignedFiles/SignedImage/") + fileName;

                // Save the image to the specified path
                File.WriteAllBytes(filePath, imageBytes);

                // Return the relative URL of the saved image
                return "~/SignedFiles/SignedImage/" + fileName;
            }
            catch (Exception ex)
            {
                // Handle exceptions
                return null;
            }
        }
        //[WebMethod]
        //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        //public static string SavePdfToServer()
        //{
        //    try
        //    {
        //        // Get the uploaded file from the request
        //        HttpPostedFile file = HttpContext.Current.Request.Files["pdfFile"];

        //        if (file != null && file.ContentLength > 0)
        //        {
        //            // Assuming ProcessID is stored in session
        //            string processid = HttpContext.Current.Session["ProcessID"].ToString();

        //            // Define the path to save the PDF (adjust path as per your project structure)
        //            string path = HttpContext.Current.Server.MapPath("~/SignedFiles/" + processid + ".pdf");

        //            // Ensure the directory exists
        //            Directory.CreateDirectory(Path.GetDirectoryName(path));

        //            // Save the file
        //            file.SaveAs(path);

        //            // Send email (you can keep your existing email logic here)
        //            SendEmail(processid, path);

        //            // Return success message
        //            return "PDF saved successfully to SignedFiles folder.";
        //        }
        //        else
        //        {
        //            throw new ApplicationException("No PDF file found in the request.");
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        HttpContext.Current.Response.StatusCode = 500; // Internal Server Error
        //        return "Error saving PDF: " + ex.Message;
        //    }
        //}
        public  static void SendEmail(string ProcessID, string filepath)
        {
            Database db = new Database();
            DataTable dt = new DataTable();
            string sql = "select CompanyID,SenderEmail,ReceiverEmail from xinatorcentral.dbo.tbl_TemplateSigning WHERE ID = '" + ProcessID + "' ";
            db.Execute(sql, out dt);
            if (dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];
                string SenderEmail = dr["SenderEmail"].ToString();
                string ReceiverEmail = dr["ReceiverEmail"].ToString();
                string CompanyID = dr["CompanyID"].ToString();
                string emailBody = "This your signed copy.Please keep it safe for future any transactions";

                //using (StreamReader reader = new StreamReader(HttpContext.Current.Server.MapPath("~/EmailTemplate.html")))
                //{
                //    emailBody = reader.ReadToEnd();
                //    emailBody = emailBody.Replace("[EmailBody]", "This your signed copy.Please keep it safe for future any transactions");
                //}
                string emailSubject = "Signed Copy";
                EmailProcessor e = new EmailProcessor();
                e.SendHtmlFormattedEmail(CompanyID, emailSubject, emailBody, SenderEmail, "", ReceiverEmail, "", filepath);



            }

        }
        //[WebMethod]
        //public static string GeneratePdf(string fieldData, string pdfurl)
        //{
        //    try
        //    {
        //        List<FieldData> fields = ParseFieldData(fieldData);
        //        string pdfUrl = GenerateAndSavePdf(fields, pdfurl);
        //        return pdfUrl; // Return the URL of the generated PDF
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log the exception and handle it appropriately
        //        return null;
        //    }
        //}

        //private static List<FieldData> ParseFieldData(string jsonData)
        //{
        //    JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
        //    return jsSerializer.Deserialize<List<FieldData>>(jsonData);
        //}


        private static string GenerateAndSavePdf(string pdfurl, string processid, string TID)
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
                    var pageSize = pdfPage.PdfDocument.PageSize;

                    if (field.FieldType == "TextBox")
                    {
                        // Calculate Y position considering PDF's coordinate system
                        float yPosition = (float)ConvertPercentageToAbsolute(96 - field.TopPosition, pageSize.Height);

                        // Adjust for text height if needed (remove if not necessary)
                        float fontSize = 12f; // Example font size, adjust according to your needs
                        float textHeight = fontSize / 2f; // Estimate text height based on font size
                        yPosition -= textHeight;

                        ColumnText.ShowTextAligned(pdfPage, Element.ALIGN_LEFT, new Phrase(field.Value, new Font(Font.FontFamily.HELVETICA, fontSize)),
                            (float)ConvertPercentageToAbsolute(field.LeftPosition, pageSize.Width),
                            yPosition, 0);
                    }
                    else if (field.FieldType == "signature")
                    {
                        Image signatureImage = Image.GetInstance(new Uri(HttpContext.Current.Server.MapPath(field.Value)));
                        signatureImage.SetAbsolutePosition(
                            (float)ConvertPercentageToAbsolute(field.LeftPosition, pageSize.Width),
                            (float)ConvertPercentageToAbsolute(96 - field.TopPosition, pageSize.Height) - signatureImage.ScaledHeight);
                        pdfPage.AddImage(signatureImage);
                    }
                }

                pdfStamper.FormFlattening = true;
                pdfStamper.Close();
                pdfReader.Close();
            }

            return outputPdfPath;
        }


        private static double ConvertPercentageToAbsolute(double percentage, double total)
        {
            return (percentage / 100) * total;
        }
    }
}