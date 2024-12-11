using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SigningFormGenerator
{
    public class UserInfo
    {
        public string CompanyID = "";
        public string CompanyName = "";

        public string UserID = "";
        public string UserName = "";
        public string AppName = "";

        public string ProductType = "";
        public string PaymentType = "";


        public string Email = "";
        public string Industry = "";
        public string ZipCode = "";

        public string FirstName = "";
        public string LastName = "";
        public string Password = "";
        public string ErrorMessage = "";





        public bool Verified = false;
        public bool IsMasterAdmin = false;
        public bool IsExist = false;


    }
}