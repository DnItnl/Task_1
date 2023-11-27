using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace Task_1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    /// 
    public partial class MainWindow : Window
    {
        private string selectedStatus = string.Empty;
        string[] statuses = { "NULL","Processing","Shipped","Delivered", "Cancelled" };
        static internal string conStrT = $@"Server={ConfigurationManager.AppSettings["ServerName"]};Database={ConfigurationManager.AppSettings["Database"]};Trusted_Connection=True;";
        string selectQuery = "pGetOrders";
         string updateQuery = "pUpdateStatus";
        static internal SqlConnection connection = null;
        DataTable Table = new DataTable();
        static SqlDataAdapter adapter;
        //static private string conStrU = @"Server=;Database=;User Id=admin;Password=;";
        public MainWindow()
        {
            InitializeComponent();
            Loaded(null, null);
        }

        private void Loaded(object sender, RoutedEventArgs e)
        {
            try
            {

                using (connection = new SqlConnection(conStrT))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand($"{selectQuery} {statuses[CBStatus.SelectedIndex]}", connection))
                    {
                        adapter = new SqlDataAdapter(command);
                        Table.Clear();
                        adapter.Fill(Table);
                        MyDataGrid.ItemsSource = Table.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                if (connection != null)
                    connection.Close();
            }
        }
        private List<int> GetSelectedIDs()
        {
            List<int> selectedIDs = new List<int>();
            foreach (var selectedItem in MyDataGrid.SelectedItems)
            {
                DataRowView row = selectedItem as DataRowView;
                if (row != null)
                {
                    int id = Convert.ToInt32(row["ID"]);
                    selectedIDs.Add(id);
                }
            }
            return selectedIDs;
        }

        private void UpdateStatusBTN_Click(object sender, RoutedEventArgs e)
        {
            List<int> selectedIDs = GetSelectedIDs();
            string idString = string.Join(",", selectedIDs);

            using (SqlConnection connection = new SqlConnection(conStrT))
            {
                connection.Open();
                

                using (SqlCommand command = new SqlCommand(updateQuery, connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@status", selectedStatus);
                        command.Parameters.AddWithValue("@ids", idString);
                        command.ExecuteNonQuery();

                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message);
                    }
                }
                using (SqlCommand command = new SqlCommand($"{selectQuery} {statuses[CBStatus.SelectedIndex]}", connection))
                {
                    adapter = new SqlDataAdapter(command);
                    if(Table != null)
                    Table.Clear();

                    adapter.Fill(Table);
                    MyDataGrid.ItemsSource = Table.DefaultView;
                }
            }

        }

        private void RadioButton_Checked(object sender, RoutedEventArgs e)
        {
            RadioButton radioButton = sender as RadioButton;
            
            if (radioButton != null && radioButton.IsChecked == true)
            {
                selectedStatus = radioButton.Content.ToString(); 
            }
        }

        private void SupplyBTN_Click(object sender, RoutedEventArgs e)
        {
            FromSupplier SupplerWindow = new FromSupplier(conStrT);
            SupplerWindow.Show();
        }
    }
}
