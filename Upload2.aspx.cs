using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class Upload2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            if (!IsPostBack)
            {
                LoadFieldName();
            }
          
        }
        public void LoadFieldName()
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            if (HttpContext.Current.Session["SigingList"] == null)
            {
                return;
            }
            SigingList s = (SigingList)HttpContext.Current.Session["SigingList"];

            string TemplateID = s.TID;
            TID.Value = TemplateID;
            string Sql = @"SELECT td.FieldID, tsd.Value, td.TID
                            FROM   tbl_TemplateDetails as td Left outer JOIN
                                         tbl_TemplateSigningDetails  as tsd ON td.TID = tsd.TID AND td.fieldID = tsd.FieldID
                            WHERE (tsd.Value = N'') AND (td.TID = N'"+ TemplateID + "') ";
            Database db = new Database();
            DataTable _datatable = new DataTable();
            db.Execute(Sql, out _datatable);

            if (_datatable.Rows.Count > 0)
            {

                optFields.DataSource = _datatable;
                optFields.DataValueField = "fieldID";
                optFields.DataTextField = "fieldID";
                optFields.DataBind();
                optFields.Items.Insert(0, new ListItem("Select Editable Field", ""));


            }


        }
        protected void lnkEmail_Click1(object sender, EventArgs e)
        {
            if (HttpContext.Current.Session["SigingList"] == null)
            {
                return;
            }
            if (optFields.Items.Count < 0)
            {
                return;
            }
            SigingList s = (SigingList)HttpContext.Current.Session["SigingList"];
            EmailProcessor ep = new EmailProcessor();
            string CompanyID = Session["CompanyID"].ToString();
            string EmailTo = txt_EmailTO.Text;
            string EmailCC = txt_EmailCC.Text;
            string EmailBCC = txt_EmailBCC.Text;
            string Sql = "";


            string processID = s.SID;
            string TemplateID = s.TID;
            string Sender = txt_EmailFrom.Text;

            string returnString = "";
            DateTime currentDate = DateTime.Now.Date;


         
           
            //Sql = " INSERT INTO XinatorCentral.dbo.tbl_TemplateSigning (ID, TID, SenderEmail, ReceiverEmail,CompanyID)" +
            //               " VALUES('" + processID + "','" + TemplateID + "','" + Sender + "','" + EmailTo + "','" + CompanyID + "')";

            Sql = " UPDATE XinatorCentral.dbo.tbl_TemplateSigning  SET SenderEmail ='"+ Sender + "', ReceiverEmail ='"+ EmailTo + "', SendDate ='"+ currentDate + "'  WHERE(TID = N'"+ TemplateID + "' and ID=N'"+processID+"' )";

            List<string> selectedValues = new List<string>();

            // Iterate through each item in the ListBox
            foreach (ListItem listItem in optFields.Items)
            {
                if (listItem.Selected)
                {
                    // Add the selected value to the list
                    selectedValues.Add(listItem.Value);
                }
            }

            if (selectedValues.Count > 0)
            {
                foreach (string si in selectedValues)
                {

                    if (si.ToString() != "0"|| si.ToString() != "")
                    {
                        Sql += " Update tbl_TemplateSigningDetails set IsEditable=1 where fieldID='" + si + "' and TID='" + TemplateID + "' and TSID='"+ processID + "' ";
                    }
                }

              
            }
            Database db = new Database();
            db.Open();
            db.Execute(Sql);
            db.Close();

            string EmailSubject = txt_EmailSubject.Text;
            string EmailBody = txt_EmailBody.Text;
            //EmailBody = EmailBody.Replace("[First Name]", FirstName);
            //EmailBody = EmailBody.Replace("[Last Name]", LastName);
            //EmailBody = EmailBody.Replace("[Full Name]", FirstName + " " + LastName);

            //EmailSubject = EmailSubject.Replace("[First Name]", FirstName);
            //EmailSubject = EmailSubject.Replace("[Last Name]", LastName);
            //EmailSubject = EmailSubject.Replace("[Full Name]", FirstName + " " + LastName);

            if (!string.IsNullOrEmpty(EmailBody))
            {
                //EmailBody = EmailBody + "<tr><td> <br/><br/ ><a href='" + surveyUrl + "'><button  onMouseOver=\"this.style.cursor = 'pointer'\" style='display: inline-block; padding: 6px 12px; margin-bottom: 0; font-size: 14px;  font-weight: normal; " +
                //           "line-height: 1.42857143; text-align: center; white-space: nowrap;vertical-align: middle; cursor: pointer; background-color: #6c757d;color:white; border: 1px solid transparent;" +
                //           " border-radius: 4px; padding: 10px 16px; '> Start Rating </button></a></td></tr>";
                string SignUrl = ConfigurationManager.AppSettings["SiningUrl"].ToString() + processID;
                if (!string.IsNullOrEmpty(EmailTo))
                {
                    //using (StreamReader reader = new StreamReader(Server.MapPath("~/EmailTemplate.html")))
                    //{
                    //    string emailBody = reader.ReadToEnd();
                    //    emailBody = emailBody.Replace("[EmailBody]", EmailBody);
                    //    EmailBody = emailBody;
                    //}
                    ep.SendHtmlFormattedEmail(CompanyID, EmailSubject, EmailBody, EmailTo, SignUrl, EmailCC, EmailBCC);

                }

            }
            Response.Redirect("ProcessList.aspx");

        }
        protected void lnkBack_CLick(object sender, EventArgs e)
        {
            SigingList s = (SigingList)HttpContext.Current.Session["SigingList"];
            Response.Redirect("TemplateSend.aspx?b=1&TID=" + TID.Value+ "&SID="+ s.SID);
        }
        }
}