using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.Services;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using System.Web.Services;
using System.Web.Script.Services;
using Org.BouncyCastle.Asn1.Ocsp;

namespace SigningFormGenerator
{
    public partial class TemplateSend : System.Web.UI.Page
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
                   
                }
                if (Request.Params["SID"] != null && Request.Params["b"]!=null)
                {
                    SigingList s = new SigingList();
                    s = (SigingList)Session["SigingList"];
                    TemplateID.Value = s.TID;
                    TSID.Value = s.SID;
                    DocName.Value = s.DocumentName;
                }
                else
                {
                    HttpContext.Current.Session.Remove("SigingList");
                }
                //if (Session["SigingList"] != null)
                //{
                //    SigingList s = new SigingList();
                //    s = (SigingList)Session["SigingList"];
                //    TemplateID.Value = s.TID;
                //    TSID.Value = s.SID;
                //    DocName.Value = s.DocumentName;
                //}
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
                TemplateName.InnerText = dr["TemplateName"].ToString();

                Session["UploadedPdfUrl"] = pdfUrl.Value;
                Session["TemplateName"] = TemplateName.InnerText;
            }

        }
      
        public static string SaveSignatureImage(string imageData)
        {
            try
            {
                if (!string.IsNullOrEmpty(imageData))
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
                else
                {
                    return null;
                }
               
            }
            catch (Exception ex)
            {
                // Handle exceptions
                return null;
            }
        }



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static void SaveFields(List<FieldData> fields, string pdfUrl,string TID,string DocName)
        {
            
            string sigingguid = Guid.NewGuid().ToString();
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            string CreatedBy = HttpContext.Current.Session["UserID"].ToString();

            if (HttpContext.Current.Session["SigingList"] != null)
            {
                SigingList si = (SigingList)HttpContext.Current.Session["SigingList"];
                sigingguid = si.SID;
            }

            

            string query = "delete from XinatorCentral.dbo.tbl_TemplateSigning where TID='"+ TID + "' and ID='"+ sigingguid + "'; ";
            query += "delete from XinatorCentral.dbo.tbl_TemplateSigningDetails where TID='" + TID + "' and TSID='" + sigingguid + "'; ";

            query += " INSERT INTO XinatorCentral.dbo.tbl_TemplateSigning (ID, TID,CompanyID,DocName)" +
                         " VALUES('" + sigingguid + "','" + TID + "', '" + CompanyID + "', '" + DocName + "')";

            foreach (var field in fields)
            {
                string value = field.Value;
                if (field.FieldType == "signature")
                {
                    value = SaveSignatureImage(value);

                }

                query += "INSERT INTO XinatorCentral.dbo.tbl_TemplateSigningDetails " +
                    "(TID,TSID,  Value, fieldID)" +
                        "VALUES('" + TID + "','" + sigingguid + "', '" + value + "','" + field.ID + "')";

            }

            Database db = new Database();
            db.Open();
            db.Execute(query);
            db.Close();
            SigingList s = new SigingList();
            s.TID = TID;
            s.fieldDatas = fields;
            s.SID = sigingguid;
            s.DocumentName = DocName;
            HttpContext.Current.Session.Remove("SigingList");
            HttpContext.Current.Session["SigingList"] = s;
            HttpContext.Current.Session.Remove("UploadedPdfUrl");
            HttpContext.Current.Session.Remove("TemplateName");
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<FieldData> SentTemplateByID(string TID,string SID)
        {
            string sql = @"SELECT td.ID, td.TID, td.FieldType, td.LeftPosition, td.TopPosition, td.fieldID, tsd.Value, tsd.CreatedDateTime, 
             tsd.TSID, td.PageNumber
                FROM   tbl_TemplateDetails as td INNER JOIN
             tbl_TemplateSigningDetails as tsd ON td.TID = tsd.TID AND td.fieldID = tsd.FieldID
                where td.TID='"+ TID + "' and tsd.TSID='"+ SID + "'";

            Database db = new Database();
            DataTable dt = new DataTable();
            db.Open();
            db.Execute(sql,out dt);
            db.Close();

            List<FieldData> fl = new List<FieldData>();
            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    FieldData f = new FieldData();
                    f.Value = dr["Value"].ToString();
                    f.ID= dr["fieldID"].ToString();
                    f.LeftPosition = Convert.ToDouble(dr["LeftPosition"].ToString());
                    f.TopPosition = Convert.ToDouble(dr["TopPosition"].ToString());
                    f.PageNumber= Convert.ToInt16(dr["PageNumber"].ToString());
                    f.FieldType =  dr["FieldType"].ToString() ;

                    fl.Add(f);
                }
            }
            return fl;

        }
    }

}
