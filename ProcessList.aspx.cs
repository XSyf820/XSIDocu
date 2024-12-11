using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class ProcessList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadTemplateData();
        }

        private void LoadTemplateData()
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            string tags = "";
            List<string> TagIDList = new List<string>();



            string sql = @"SELECT ts.TID, ts.ID, ts.SenderEmail, ts.ReceiverEmail, ts.DocName, ts.SendDate, ts.SignedDate, tl.TemplateName
                            FROM   tbl_TemplateList as tl INNER JOIN
                                         tbl_TemplateSigning as ts ON tl.ID = ts.TID  where tl.CompanyID='" + CompanyID + "';";


            DataTable dt = new DataTable();
            Database db = new Database();


            db.Execute(sql, out dt);
            StringBuilder table = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                // Add customer data to the table


                string ProcessID = row["ID"].ToString();
                string SenderEmail = row["SenderEmail"].ToString();
                string ReceiverEmail = row["ReceiverEmail"].ToString();
                string SendDate = row["SendDate"].ToString(); 
                 string SignedDate = row["SignedDate"].ToString(); 
                string TemplateName = row["TemplateName"].ToString();
                string DocName = row["DocName"].ToString();

                if (!string.IsNullOrEmpty(SendDate))
                {
                    SendDate = Convert.ToDateTime(SendDate).ToString("dd/MM/yyyy");
                }
                if (!string.IsNullOrEmpty(SignedDate))
                {
                    SignedDate = Convert.ToDateTime(SignedDate).ToString("dd/MM/yyyy");
                }

                table.Append("<tr>");
                //table.Append("<td>" + ProcessID + "</td>");
                table.Append("<td>" + TemplateName + "</td>");
                table.Append("<td>" + DocName + "</td>");
                table.Append("<td>" + SenderEmail + "</td>");
                table.Append("<td>" + ReceiverEmail + "</td>");
                table.Append("<td>" + SendDate + "</td>");
                table.Append("<td>" + SignedDate + "</td>");
                table.Append("<td><center><a href='ViewPdf.aspx?guid=" + ProcessID + "'><i  class='btn btn-primary action' title='View'   style='color:white!important;text-align:center'><i class='fa fa-eye'></i></i></a></center></td>");
                table.Append("</tr>");


            }

            ListTable.Controls.Add(new Literal { Text = table.ToString() });

        }
    }
}