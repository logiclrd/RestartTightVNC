<%@ Page Language="C#" %>
<%@ Assembly Name="System.ServiceProcess, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %>
<%@ Import Namespace="System.ServiceProcess" %>
<%@ Import Namespace="System.Threading" %>
<html>
  <form>
    <input type="button" id="cmdRestart" value="Restart TightVNC Server" onclick="Action()" />
  </form>

  <results id="pnlResults">

    <%
      if (Request.HttpMethod == "POST")
      {
        try
        {
          var controller = new ServiceController("tvnserver");

          Response.Write("Stage 1 status: " + controller.Status + "<br />");

          controller.Stop();

          Response.Write("Stage 2 status: " + controller.Status + "<br />");

          controller.WaitForStatus(ServiceControllerStatus.Stopped);

          Response.Write("Stage 3 status: " + controller.Status + "<br />");

          controller.Start();

          for (int retry = 0; retry < 100; retry++)
          {
            controller = new ServiceController("tvnserver");

            Response.Write("Stage 4 status: " + controller.Status + "<br />");

            if (controller.Status == ServiceControllerStatus.Running)
              break;

            Thread.Sleep(100);
          }
        }
        catch (Exception e)
        {
          Response.Write("ERROR: " + e.GetType().Name + ": " + e.Message);
        }
      }
    %>

  </results>

  <script>

    var cmdRestart = document.getElementById("cmdRestart");
    var pnlResults = document.getElementById("pnlResults");

    function Action()
    {
      var request = new XMLHttpRequest();

      request.onreadystatechange =
        function()
        {
          if (this.readyState == 4)
          {
            var contents = this.responseText;

            var parser = new DOMParser();

            try
            {
              var doc = parser.parseFromString(contents, "text/xml");

              var resultsNode = doc.querySelector("results");

              pnlResults.innerHTML = new XMLSerializer().serializeToString(resultsNode);
            }
            catch (error)
            {
              alert("fallback: " + error);
            }
          }
        };

      request.open("POST", "default.aspx", true);
      request.send();
    }

    cmdRestart.onclick = Action;

  </script>
</html>

