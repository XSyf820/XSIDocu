using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class TemplateCreate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            if (!IsPostBack)
            {
                if (Request.Params["TID"] != null)
                {
                    TemplateID.Value = Request.Params["TID"].ToString();
                    GetPdfUrl(TemplateID.Value);
                    Mode.Value = "Edit";
                    btn_UpdateFields.Visible = true;
                    saveFields.Visible = false;
                }
                else
                {
                    if(Request.Params["n"] != null)
                    {
                        Session.Remove("UploadedPdfUrl");
                        Session.Remove("TemplateName");
                    }
                   
                   
                    btn_UpdateFields.Visible = false;
                    saveFields.Visible = true;
                    Mode.Value = "Add";
                }
            }
          
        }

      
        public void GetPdfUrl(string guid)
        {
            string pdfurl = "";
            string sql = @"SELECT *FROM tbl_TemplateList where ID = N'" + guid + "'";
            Database db = new Database();
            DataTable dt = new DataTable();
            db.Execute(sql, out dt);
            if (dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];
                pdfUrl.Value = dr["PdfUrl"].ToString();
                 TemplateName.Value = dr["TemplateName"].ToString();

                Session["UploadedPdfUrl"] = pdfUrl.Value;
                Session["TemplateName"] = TemplateName.Value;
            }

        }
        protected void UploadButton_Click(object sender, EventArgs e)
        {
            if (TemplateUpload.HasFile)
            {
                string TemplateID = DateTime.Now.ToString("yyyyMMddHHmmssfff");
                string fileName = Path.GetFileName(TemplateUpload.PostedFile.FileName);
                fileName = TemplateID+"_" + fileName;

                string savePath = Server.MapPath("~/UploadedFiles/") + fileName;
                TemplateUpload.SaveAs(savePath);

                // Set the session variable to the uploaded PDF's URL
                Session["UploadedPdfUrl"] = "UploadedFiles/" + fileName;
                Session["TemplateName"] = TemplateName.Value;

                UploadedPdfUrl.Value = "UploadedFiles/" + fileName;
                // Redirect to the same page to display the uploaded PDF
                Response.Redirect("TemplateCreate.aspx");
            }
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
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static void SaveFields(List<FieldData> fields, string pdfUrl,string mode,string templateName)
        {
            string query = "";
            if (mode == "Add")
            {
                string guid = Guid.NewGuid().ToString();
                string sigingguid = Guid.NewGuid().ToString();

                string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
                string CreatedBy = HttpContext.Current.Session["UserID"].ToString();

                  query = "INSERT INTO XinatorCentral.dbo.tbl_TemplateList (ID, PdfUrl, CompanyID,CreatedBy,TemplateName) " +
                                       "VALUES ('" + guid + "', '" + pdfUrl + "','" + CompanyID + "','" + CreatedBy + "','" + templateName + "')";

                foreach (var field in fields)
                {
                    string value = field.Value;
                    //if (field.FieldType == "custom")
                    //{
                    //    value = SaveSignatureImage(value);

                    //}

                    query += "INSERT INTO XinatorCentral.dbo.tbl_TemplateDetails " +
                        "(TID, FieldType, LeftPosition, TopPosition, fieldID,PageNumber)" +
                            "VALUES('" + guid + "','" + field.FieldType + "','" + field.LeftPosition + "','"
                            + field.TopPosition + "','" + field.ID + "','" + field.PageNumber + "')";


                }
                Database db = new Database();
                db.Open();
                db.Execute(query);
                db.Close();
                HttpContext.Current.Session.Remove("UploadedPdfUrl");
                HttpContext.Current.Session.Remove("TemplateName");

            }
           

           
           
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static void UpdateFields(SigingList siging, string pdfUrl)
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            string CreatedBy = HttpContext.Current.Session["UserID"].ToString();
            string connectionString = ConfigurationManager.AppSettings["ConnString"].ToString();
            Database db = new Database();
            string query = "";
            List<FieldData> fields = siging.fieldDatas;

            //query = "INSERT INTO XinatorCentral.dbo.tbl_TemplateList (ID, PdfUrl, CompanyID,CreatedBy) " +
            //                       "VALUES ('" + guid + "', '" + pdfUrl + "','" + CompanyID + "','" + CreatedBy + "')";
            query = @"UPDATE tbl_TemplateList
                        SET TemplateName ='"+ siging.TemplateName+ "' WHERE(ID = N'"+ siging.TID+ "')";

            query += @" DELETE FROM tbl_TemplateDetails  WHERE(TID = N'" + siging.TID+ "')";

            foreach (var field in fields)
            {
                string value = field.Value;
                //if (field.FieldType == "custom")
                //{
                //    value = SaveSignatureImage(value);

                //}

                query += "INSERT INTO XinatorCentral.dbo.tbl_TemplateDetails " +
                    "(TID, FieldType, LeftPosition, TopPosition, fieldID,PageNumber)" +
                        "VALUES('" + siging.TID + "','" + field.FieldType + "','" + field.LeftPosition + "','"
                        + field.TopPosition + "','" + field.ID + "','" + field.PageNumber + "')";


            }
            

            db.Open();
            db.Execute(query);
            db.Close();
            HttpContext.Current.Session.Remove("UploadedPdfUrl");
            HttpContext.Current.Session.Remove("TemplateName");

        }

        [WebMethod]
        public static List<FieldData> GetSavedFields(string TID)
        {
            List<FieldData> savedFields = new List<FieldData>();
            string connectionString = ConfigurationManager.AppSettings["ConnString"].ToString();

            Database db = new Database();
            DataTable dt = new DataTable();
            string sql = "SELECT  PageNumber,fieldID,FieldType, LeftPosition, TopPosition FROM tbl_TemplateDetails WHERE TID = '" + TID + "'";
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
                    field.PageNumber = Convert.ToInt32(dr["PageNumber"].ToString());

                    //field.Value = dr["Value"].ToString();
                   // field.IsEditable = Convert.ToBoolean(dr["IsEditable"].ToString());
                    savedFields.Add(field);
                }
            }
           
            return savedFields;
        }


    }
}