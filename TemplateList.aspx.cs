using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class TemplateList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
            }

            LoadTemplateData();
        }

        private void LoadTemplateData()
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();

            // Placeholder for fetching and displaying data
            // You can replace this section with your desired functionality.
            string sql = @"select * from XinatorCentral.dbo.tbl_TemplateList where CompanyID='" + CompanyID + "';";

            DataTable dt = new DataTable();
            Database db = new Database();

            db.Execute(sql, out dt);

            // Placeholder for handling the fetched data
            // This logic can be customized as per your requirements.
            foreach (DataRow row in dt.Rows)
            {
                string TemplateID = row["ID"].ToString();
                string TemplateName = row["TemplateName"].ToString();

                // Add logic here to process or display TemplateName or other data if needed
                // For example, you could dynamically populate a different UI component
            }

            // Optional: Add any controls or dynamic elements here
            // Example: ListPlaceholder.Controls.Add(new Literal { Text = "Custom Content" });
        }
    }
}
