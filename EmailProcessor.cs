using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace SigningFormGenerator
{
  
    public class EmailProcessor
    {
        string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
        static string connStrStatic = ConfigurationManager.AppSettings["ConnString"].ToString();

        public string SendHtmlFormattedEmail(string CompanyID,   string subject, string body, string recepientToEmail, string docUrl, string EmailCC, string EmailBCC, string filePath="")
        {
            string status = "";


            string CompanyAddress = "";
            string CompanyCity = "";
            string CompanyState = "";
            string CompanyZipCode = "";
            string CompanyPhone = "";
            string CompanyEmail = "";
            string CompanyWebsite = "";
            string CompanyFacebook = "";
            string CompanyTwitter = "";
            string CompanyLogoFile = "";
            string CompanyFullName = "";
            string CompanyGUID = "";
            string CompanyEmailBranding = "";
            string EmailFrom = "";
            string MailStatus = string.Empty;


            try
            {
                Database db = new Database(connStr);

                string sql = "";
                if (HttpContext.Current.Session["isPro"] != null)
                {

                    sql = "select address1 as Address,*from Mobilize.dbo.tbl_Company where CompanyID='" + CompanyID + "'";
                }
                else
                {
                    sql = "select*from XinatorCentral.dbo.tbl_Company where CompanyID='" + CompanyID + "'";
                }


                DataTable dt = new DataTable();
                string LogoPath = "";
                //  db.Open();
                db.Execute(sql, out dt);

                if (dt.Rows.Count > 0)
                {
                    DataRow Rs = dt.Rows[0];
                    CompanyAddress = Rs["Address"].ToString();
                    CompanyCity = Rs["City"].ToString();
                    CompanyState = Rs["State"].ToString();
                    CompanyZipCode = Rs["ZipCode"].ToString();
                    CompanyPhone = Rs["Phone"].ToString();
                    CompanyEmail = Rs["Email"].ToString();
                    CompanyEmailBranding = Rs["EmailBranding"].ToString();

                    CompanyFullName = Rs["CompanyName"].ToString();
                    //CompanyGUID = Rs["CompanyGUID"].ToString();
                    CompanyLogoFile = Rs["LogoFile"].ToString();
                    LogoPath = HttpContext.Current.Server.MapPath("~/CompanyLogo/" + CompanyLogoFile);
                }



                if (!string.IsNullOrEmpty(body))
                {
                    body = body.Replace("[Company Name]", CompanyFullName);
                    body = body.Replace("[Address]", CompanyAddress + "," + CompanyCity + "," + CompanyState + " " + CompanyZipCode);
                    body = body.Replace("[Phone]", CompanyPhone);
                    body = body.Replace("[Email]", CompanyEmail);

                }

                string Emailbody = "";
                using (StreamReader reader = new StreamReader(HttpContext.Current.Server.MapPath("~/EmailTemplate.html")))
                {
                    Emailbody = reader.ReadToEnd();
                    Emailbody = Emailbody.Replace("[EmailBody]", body);
                }
                if (!string.IsNullOrEmpty(docUrl))
                {
                    Emailbody = Emailbody.Replace("[buttonUrl]" ," <td style='background-color: rgb(0, 210, 244); padding: 12px 35px; border-radius: 50px;' align='center' class='ctaButton'><a href='" + docUrl + "' style='color:#fff;font-family:Poppins,Helvetica,Arial,sans-serif;font-size:13px;font-weight:600;font-style:normal;letter-spacing:1px;line-height:20px;text-transform:uppercase;text-decoration:none;display:block' target='_blank' class='text'>Review Document</a></td>");


                }
                else
                {
                    Emailbody = Emailbody.Replace("[buttonUrl]", " ");

                }

                //string url = ConfigurationManager.AppSettings["SurveyResponse"].ToString() + CompanyGUID + "&CustomerID=" + CustomerID + "&CompanyID=" + CompanyID + "&Email=" + recepientEmail + "&SurveyID=" + SurveyID + "";



                if (!string.IsNullOrEmpty(body))
                {
                    //Emailbody = Emailbody.Replace("[Company Name]", CompanyFullName);
                    //Emailbody = Emailbody.Replace("[Address]", CompanyAddress + "," + CompanyCity + "," + CompanyState + " " + CompanyZipCode);
                    //Emailbody = Emailbody.Replace("[Phone]", CompanyPhone);
                    //Emailbody = Emailbody.Replace("[Email]", CompanyEmail);
                    StringBuilder builder = new StringBuilder(Emailbody);
                    //builder.Replace("\r", "<br />")  ;
                    //builder.Replace("@#", "<br />");
                    Emailbody = builder.ToString();

                }




                if (string.IsNullOrEmpty(CompanyLogoFile))
                {
                    LogoPath = HttpContext.Current.Server.MapPath("~/Assets/images/logo/central.png");
                }


                string header = "";

                string BodyText = "";
                string wisetackFooter = "";




                //   BodyText = "<body><table style='max-width:800px; font-family:Arial;font-size:13px;'>" +
                //"<tr><td align='left'><table width='100%'><tr><td>" +
                //"<img src=\"cid:photo\"  id='img' alt='' style='max-height:60px;' height='60' /></td>" +
                //"<td align='center' style='color:#2980b9; vertical-align:bottom;'>" +
                //"</td></tr></table></td></tr>" +
                //"<tr><td align='left' style='padding-left:5px;'>" +
                //Emailbody +
                //       "</td></tr>";

                //   BodyText = BodyText + "</table></td></tr></table></body>";
                BodyText = Emailbody;
                string attachedfileNames = "";
                try
                {
                    using (MailMessage mailMessage = new MailMessage())
                    {


                        if (!string.IsNullOrEmpty(recepientToEmail))
                        {
                            string[] recepientToList = recepientToEmail.Split(',');
                            foreach (string multiple_email in recepientToList)
                            {
                                mailMessage.To.Add(new MailAddress(multiple_email));

                            }
                        }

                        if (!string.IsNullOrEmpty(EmailCC))
                        {
                            string[] recepientToList = EmailCC.Split(',');
                            foreach (string multiple_email in recepientToList)
                            {
                                mailMessage.CC.Add(new MailAddress(multiple_email));

                            }
                        }
                        if (!string.IsNullOrEmpty(EmailBCC))
                        {
                            string[] recepientToList = EmailBCC.Split(',');
                            foreach (string multiple_email in recepientToList)
                            {
                                mailMessage.Bcc.Add(new MailAddress(multiple_email));

                            }
                        }

                        if (string.IsNullOrEmpty(CompanyEmail))
                        {
                            EmailFrom = "noreply@" + CompanyID + ".com";
                        }
                        else
                        {
                            EmailFrom = CompanyEmail;
                        }



                        if (!string.IsNullOrEmpty(CompanyEmailBranding))
                            mailMessage.From = new MailAddress(EmailFrom, CompanyEmailBranding);
                        else mailMessage.From = new MailAddress(EmailFrom);



                        mailMessage.Subject = subject;
                        mailMessage.Body = Emailbody;

                        if (!string.IsNullOrEmpty(CompanyLogoFile))
                        {

                            if (File.Exists(LogoPath))
                            {
                                AlternateView htmlview = default(AlternateView);
                                htmlview = AlternateView.CreateAlternateViewFromString(BodyText, null, "text/html");
                                LinkedResource imageResourceEs = new LinkedResource(LogoPath, MediaTypeNames.Image.Jpeg)
                                {
                                    ContentId = "photo"
                                };
                                //imageResourceEs.ContentId = "photo";
                                //imageResourceEs.TransferEncoding = System.Net.Mime.TransferEncoding.Base64;
                                htmlview.LinkedResources.Add(imageResourceEs);
                                mailMessage.AlternateViews.Add(htmlview);
                            }
                            else
                            {
                                mailMessage.Body = Emailbody;
                            }

                        }
                        else
                        {
                            mailMessage.Body = Emailbody;
                        }
                        if (!string.IsNullOrEmpty(filePath))
                        {
                            Attachment attachment = new Attachment(filePath);
                            mailMessage.Attachments.Add(attachment);
                            HttpContext.Current.Session["ProcessID"] = null;
                        }
                        
                        mailMessage.IsBodyHtml = true;
                        string emailSentError = "";

                        SmtpClient smtp = new SmtpClient();
                        smtp.Host = ConfigurationManager.AppSettings["SMTP"];
                        smtp.EnableSsl = true;
                        System.Net.NetworkCredential NetworkCred = new System.Net.NetworkCredential();
                        NetworkCred.UserName = ConfigurationManager.AppSettings["SmtpUser"];
                        NetworkCred.Password = ConfigurationManager.AppSettings["SmtpPassword"];
                        smtp.UseDefaultCredentials = true;
                        smtp.Credentials = NetworkCred;
                        smtp.Port = int.Parse(ConfigurationManager.AppSettings["Port"]);

                        smtp.Send(mailMessage);

                    }
                    status = "Success";
                    MailStatus = "Success";
                }
                catch (Exception ex)
                {
                    status = ex.Message;
                    MailStatus = "Failed";
                }

               
                return status;
                db.Close();


            }
            catch (Exception ex)
            {
                status = ex.Message;
                EmailProcessor.Log(status);

                return ex.Message;
            }


        }
        public static void Log(string message)
        {


            string logFilePath = HttpContext.Current.Server.MapPath("~/Log.txt");

             
            using (StreamWriter writer = new StreamWriter(logFilePath, true))
            {
                writer.WriteLine($"{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")} - {message}");
            }


        }
        public string rtnString(string sqlStr)
        {

            try
            {
                using (SqlConnection sqlCon = new SqlConnection(connStr))
                {
                    sqlCon.Open();
                    SqlCommand sqlCmd = new SqlCommand(sqlStr, sqlCon);
                    SqlDataReader sqlDr = sqlCmd.ExecuteReader();
                    while (sqlDr.Read())
                    {
                        if (sqlDr[0] != DBNull.Value)
                        {
                            return sqlDr[0].ToString();
                        }
                    }
                }
                return String.Empty;
            }
            catch (SqlException ex)
            {
                throw ex;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public static string GetUniqueID()
        {
            Database db = new Database();
            DataTable dt = new DataTable();
            string guid = "";
            bool isUnique = false;
            while (!isUnique)
            {
                guid = Guid.NewGuid().ToString().Substring(0, 20);
                string sql = "SELECT Guid FROM ReviewManagement.dbo.tbl_DripCampaign WHERE Guid = '" + guid + "'";
                db.Open();
                int count;
                db.Execute(sql, out dt);
                db.Close();

                if (dt.Rows.Count <= 0)
                {
                    isUnique = true;
                }
            };

            return guid;
        }
    }
    public class SigingList
    {
        public string SID { get; set; }
        public string TID { get; set; }
        public string TemplateName { get; set; }
        public string DocumentName { get; set; }

        public List<FieldData> fieldDatas { get; set; }

    }
    public class FieldData
    {
        public string FieldType { get; set; }
        public double LeftPosition { get; set; }
        public double TopPosition { get; set; }
        public string Value { get; set; }
        public string ID { get; set; }
        public int PageNumber { get; set; }

        //public string guid { get; set; }
        //public string SID { get; set; }//
        public bool IsEditable { get; set; }

    }
    
}