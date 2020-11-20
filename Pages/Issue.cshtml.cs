using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Linq;

namespace budoco.Pages
{
    public class IssueModel : PageModel
    {

        // bindings start 
        [BindProperty]
        public int id { get; set; }

        [BindProperty]
        public string desc { get; set; }

        [BindProperty]
        public IEnumerable<SelectListItem> projects { get; set; }
        [BindProperty]
        public IEnumerable<SelectListItem> categories { get; set; }
        [BindProperty]
        public IEnumerable<SelectListItem> statuses { get; set; }
        [BindProperty]
        public IEnumerable<SelectListItem> priorities { get; set; }
        [BindProperty]
        public IEnumerable<SelectListItem> assigned_to_users { get; set; }

        [BindProperty]
        public int project_id { get; set; }
        [BindProperty]
        public int category_id { get; set; }
        [BindProperty]
        public int status_id { get; set; }
        [BindProperty]
        public int priority_id { get; set; }
        [BindProperty]
        public int assigned_to_user_id { get; set; }

        // bindings end        

        public void OnGet(int id)
        {
            PrepareDropdowns();

            //bd_util.redirect_if_not_logged_in(HttpContext);

            this.id = id;

            if (id != 0)
            {
                string sql = "select * from issues where i_id = " + id.ToString();

                DataRow dr = db_util.get_datarow(sql);

                desc = (string)dr["i_desc"];

            }
        }

        public void OnPost()
        {
            PrepareDropdowns();


            if (!IsValid())
            {
                return;
            }

            string sql;

            if (id == 0)
            {

                sql = @"insert into issues 
                (i_desc, i_created_by_user) 
                values(@i_desc, @i_created_by_user) 
                returning i_id";

                this.id = (int)db_util.exec_scalar(sql, GetValuesDict());
                bd_util.set_flash_msg(HttpContext, "Create was successful");
                Response.Redirect("Issue?id=" + this.id.ToString());
            }
            else
            {
                sql = @"update issues set 
                i_desc = @i_desc, 
                i_last_updated_user = @i_last_updated_user
                where i_id = @i_id;";

                db_util.exec(sql, GetValuesDict());
                bd_util.set_flash_msg(HttpContext, "Update was successful");
            }
        }

        Dictionary<string, dynamic> GetValuesDict()
        {
            var dict = new Dictionary<string, dynamic>();

            dict["@i_id"] = id;
            dict["@i_desc"] = desc;
            dict["@i_created_by_user"] = HttpContext.Session.GetInt32("us_id");
            dict["@i_last_updated_user"] = HttpContext.Session.GetInt32("us_id");
            return dict;
        }

        void PrepareDropdowns()
        {
            var list = PrepareSelectList("select pj_id, pj_name from projects");
            projects = new SelectList(list, "val", "nam");

            list = PrepareSelectList("select ca_id, ca_name from categories");
            categories = new SelectList(list, "val", "nam");
        }

        List<Dictionary<string, dynamic>> PrepareSelectList(string sql)
        {
            var list = new List<Dictionary<string, dynamic>>();

            DataTable dt = db_util.get_datatable(sql);
            foreach (DataRow dr in dt.Rows)
            {
                var d = new Dictionary<string, dynamic>();
                d["val"] = dr[0];
                d["nam"] = dr[1];
                list.Add(d);
            }
            return list;

        }

        bool IsValid()
        {
            var errs = new List<string>();

            if (string.IsNullOrWhiteSpace(desc))
            {
                errs.Add("Description is required.");
            }

            if (errs.Count == 0)
            {
                return true;
            }
            else
            {
                bd_util.set_flash_err(HttpContext, errs);
                return false;
            }
        }
    }
}