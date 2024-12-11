using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SigningFormGenerator
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnLogin_Click(object sender, EventArgs e)
        {


            lblError.Text = "";

            //LoginProcessor lp = new LoginProcessor();

            string UserName =   txtUsername.Text  ;
            string Password =  txtPassword.Text ;

            UserInfo userInfo = VerifyUser(UserName, Password);



            if (userInfo.Verified)
            {
                LoginUser(userInfo);
            }
            else
            {
                lblError.Text = userInfo.ErrorMessage;
            }

        }
        public UserInfo VerifyUser(string UserName, string Password)
        {
            UserInfo userInfo = new UserInfo();

            try
            {
                Database db = new Database();
                
                db.Open();

                DataTable dt = new DataTable();


                string sql = @" SELECT  [id]                    "+
                     "         ,[CompanyID]                     "+
                     "         ,[UserID]                        "+
                     "         ,[Password]                      "+
                     "         ,[FirstName]                     "+
                     "         ,[LastName]                      "+
                     "         ,[Phone]                         "+
                     "         ,[Mobile]                        "+
                     "         ,[Email]                         "+
                     "         ,[CreatedDateTime]               "+
                     "         ,[IsMasterAdmin]                 "+
                     "     FROM [XinatorCentral].[dbo].[tbl_User] " +
                             " Where UserID = '"+ UserName + "'" +
                             " And Password ='"+ Password + "'";


                
                db.Execute(sql,out dt);

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    bool IsMasterAdmin = false;
                    if (dr["IsMasterAdmin"] != null)
                    {
                        IsMasterAdmin = Convert.ToBoolean(dr["IsMasterAdmin"].ToString());

                    }
                    userInfo.IsMasterAdmin = IsMasterAdmin;
                    if (IsMasterAdmin)
                    {
                        HttpContext.Current.Session["IsAdmin"] = userInfo.IsMasterAdmin;

                    }
                    //else
                    //{
                    userInfo.Verified = true;
                    userInfo.CompanyID = dr["CompanyID"].ToString();

                    userInfo.UserName = dr["FirstName"].ToString() + " " + dr["LastName"].ToString();
                    userInfo.UserID = UserName;
                    userInfo.AppName = "Jobs";


                    //Checking user's trial period

                    sql = "Select * from XinatorCentral.dbo.tbl_Company where " +
                             "CompanyID = '"+ dr["CompanyID"].ToString() + "' ";


                     



                    DataTable dt2 = new DataTable();

                    db.Execute(sql,out dt2);
                    if (dt2.Rows.Count > 0)
                    {
                        DataRow dr1 = dt2.Rows[0];

                        bool IsActive = Convert.ToBoolean(dr1["IsActive"]);
                        bool Trial = Convert.ToBoolean(dr1["IsTrial"]);

                        if (!IsActive)
                        {

                            userInfo.Verified = false;
                            userInfo.ErrorMessage = "Your account deactivated.";
                        }
                        else if (Trial)
                        {
                            DateTime TrialEndDate = Convert.ToDateTime(dr1["TrialEndDate"]);
                            if (TrialEndDate < DateTime.Today)
                            {
                                userInfo.Verified = false;
                                userInfo.ErrorMessage = "Your trial period has been ended.Please use the Chat link to contact support to resolve this issue.";
                            }
                            else
                            {
                                userInfo.Verified = true;
                            }
                        }
                        else
                        {
                            userInfo.Verified = true;

                        }

                        //else
                        //{
                        //    userInfo.Verified = true;
                        //}

                    }
                    else
                    {
                        userInfo.Verified = false;
                        userInfo.ErrorMessage = "Invalid User name or Password";
                    }




                }
                else
                {
                    userInfo.Verified = false;
                    userInfo.ErrorMessage = "Invalid User name or Password";
                }

                db.Close();
            }
            catch (Exception ex)
            {
                userInfo.Verified = false;
                userInfo.ErrorMessage = ex.Message;
            }

            return userInfo;

        }
        public void LoginUser(UserInfo userInfo)
        {
            HttpContext.Current.Session["bLoggedin"] = "1";

            HttpContext.Current.Session["CompanyID"] = userInfo.CompanyID;
            HttpContext.Current.Session["FranchisorName"] = userInfo.CompanyID;

            HttpContext.Current.Session["UserName"] = userInfo.UserName;
            HttpContext.Current.Session["AppName"] = userInfo.AppName;
            HttpContext.Current.Session["UserID"] = userInfo.UserID;




            HttpContext.Current.Response.Redirect("TemplateList.aspx");
        }

    }
}