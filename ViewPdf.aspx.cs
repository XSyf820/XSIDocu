using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SigningFormGenerator
{
    public partial class ViewPdf : System.Web.UI.Page
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
            string sql = @"SELECT tsd.IsEditable, tsd.TSID, tsd.TID, tsd.Value, tsd.FieldID, td.PageNumber, td.FieldType, td.LeftPosition, td.TopPosition
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




                //command.Parameters.AddWithValue("@Value", field.Value);
                //command.Parameters.AddWithValue("@guid", field.guid);
                //command.Parameters.AddWithValue("@fieldid", field.ID);

                //command.ExecuteNonQuery();
            }
            //connection.Close(); // Close the connection after the loop
            db.Open();
            db.Execute(query);
            db.Close();

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




    }
}