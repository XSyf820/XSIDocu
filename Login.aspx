<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SigningFormGenerator.Login" enableEventValidation="false" %>

<!doctype html>
<html lang="en">
    <head>
    
    
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

    <title>XinatorServco</title>

   <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet" />
    
    </head>
    
<body>
    
    <form id="form" runat="server">
    <section class="login-1stsec py-5" id="homesec">
	    <div class="container">     
            
            <div class="row d-flex justify-content-center align-items-center fullHeight">
                <div class="col-12 mt-5">
	                <div class="row d-flex justify-content-center align-items-center">
		               
		                <div class="col-12 col-sm-12 col-md-6 col-lg-4 ">
		                    <div class="login-container">
		                        <h2>Sign in to Franchisor Dashboard</h2>
		                        <form method="post" action="./login.aspx" id="form1">
									<div class="">
										<input type="hidden">
									</div>
									
									<div class="">
									
										<input type="hidden">
										
									</div>
			                        
			                        <div class="row">
				                        <div class="col-12 mt-3">
											   <asp:Label ID="lblError" runat="server" ForeColor="Red"></asp:Label>
					                      <%--<span id="lblError" style="color:Red;" runat="server"></span>--%>
					                    </div>
			                        	
					                    <div class="col-12 mt-3">
											<label class="form-label mb-0">Email</label>
											<%--<input name="txtUsername" type="text" maxlength="80" id="txtUsername" class="form-control" runat="server">--%>
											<asp:TextBox ID="txtUsername" name="txtUsername" class="form-control" runat="server" MaxLength="80"></asp:TextBox>
					                    </div>
					                    <div class="col-12 mt-1">
					                      <label class="form-label mb-0">Password</label>
					                     <%-- <input name="txtPassword" type="password" maxlength="15" id="txtPassword" class="form-control" runat="server">--%>
					                     <asp:TextBox ID="txtPassword" name="txtPassword" class="form-control" runat="server" TextMode="Password" MaxLength="15"></asp:TextBox>
										</div>
					                    
					                    <div class="col-12 mt-3">
					                      <input type="checkbox" name="remember" id="remember"> <label for="remember">Remember me on this computer</label>
					                    </div>
					                    
					                    
					                    <div class="col-12 mt-3">
											  <asp:Button ID="btnLogin" type="button" class="btn btn-primary btn-logintransparent w-100"  runat="server" Text="Login" OnClick="btnLogin_Click" />
						                    <%--<input type="submit" name="btnLogin" value="Login" id="btnLogin" class="btn btn-primary btn-logintransparent w-100">--%>
					                    </div>
				                    </div>
				                    
		                        </form>
		                    </div>
		                </div>
		                
	                </div>
	                
				</div>
			</div>
	             
        </div>
    </section>
    </form>
  

  <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>


</body>
</html>
