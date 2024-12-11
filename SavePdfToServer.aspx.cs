using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.IO;
using System.Data;

namespace SigningFormGenerator
{
    public partial class SavePdfToServer : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
             
            if (Request.HttpMethod == "POST")
            {
                try
                {
                    
                    HttpPostedFile file = Request.Files["pdfFile"];

                    if (file != null && file.ContentLength > 0)
                    {
                        string processid = HttpContext.Current.Session["ProcessID"].ToString();
                        
                        string path = Server.MapPath("~/SignedFiles/" + processid + ".pdf");

                         
                        Directory.CreateDirectory(Path.GetDirectoryName(path));

                        
                        file.SaveAs(path);
                        SendEmail(processid, path);

                        
                        EmailProcessor.Log("PDF saved successfully for process ID: " + processid);

                       
                        Response.Write("PDF saved successfully to SignedFiles folder.");
                       
                    }
                    else
                    {
                        EmailProcessor.Log("No PDF file found in the request.");
                        throw new ApplicationException("No PDF file found in the request.");
                    }
                }
                catch (Exception ex)
                {
                    EmailProcessor.Log("Error saving PDF: " + ex.Message);
                    Response.StatusCode = 500; // Internal Server Error
                    Response.Write("Error saving PDF: " + ex.Message);
                }

               
            }
            Response.Redirect("Success.aspx");
        }
       
        public void SendEmail(string ProcessID,string filepath)
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
                string emailBody = "";

               
                emailBody = "This is your signed copy.Please keep it safe for future referance.";
                 string emailSubject = "Signed Copy";
                EmailProcessor e = new EmailProcessor();
                e.SendHtmlFormattedEmail(CompanyID, emailSubject, emailBody, SenderEmail, "", ReceiverEmail,"", filepath);



            }

        }
    }
}