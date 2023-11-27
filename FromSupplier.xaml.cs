using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.NetworkInformation;
using System.Reflection.Metadata;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace Task_1
{
    /// <summary>
    /// Логика взаимодействия для FromSupplier.xaml
    /// </summary>
    public partial class FromSupplier : Window
    {

        DataTable Names = new DataTable();
        SqlDataAdapter adapter;
        string conStrT;
        private static readonly Regex _regex = new Regex("[^0-9]+"); 
        private static bool IsTextAllowed(string text)
        {
            return _regex.IsMatch(text);
        }
        public FromSupplier(string conStrT)
        {
            InitializeComponent();

            this.conStrT = conStrT;
            using (SqlConnection connection = new SqlConnection(conStrT))
            {

                using (SqlCommand command = new SqlCommand($"select * from products", connection))
                {
                    Names = new DataTable();
                    adapter = new SqlDataAdapter(command);
                    adapter.Fill(Names);
                    ProdNames.ItemsSource = Names.DefaultView;
                }
            }


        }
        
        private void BTNSupply_Click(object sender, RoutedEventArgs e)
        {
            if (IsTextAllowed(TBquantity.Text)) return;
            var row = (DataRowView)ProdNames.SelectedItem; 
            using (SqlConnection connection = new SqlConnection(conStrT))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand("InsertIntoSupply", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@product_id", row["id"]);
                        command.Parameters.AddWithValue("@quantity", TBquantity.Text);
                        command.ExecuteNonQuery();

                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message);
                    }
                }
                using (SqlCommand command = new SqlCommand($"select * from products", connection))
                {
                    Names.Clear();
                    adapter = new SqlDataAdapter(command);
                    adapter.Fill(Names);
                    ProdNames.ItemsSource = Names.DefaultView;
                }
            }
        }
    }
}
