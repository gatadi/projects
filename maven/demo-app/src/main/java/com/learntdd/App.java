package com.learntdd;


import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

/**
 * Hello world!
 *
 */
public class App 
{
    String message;
    
    public static void main( String[] args )
    {
        System.out.println( "\n\n************************\n" );
        System.out.println("App.main()...\n\n");
        
        makeoAuthCall();
        
        System.out.println( "************************\n\n" );
    }
    
    public String getMessage()
    {        
        return this.message ;
    }
    
    public void setMessage(String msg)
    {
        this.message = msg ;
        this.showMessage();
    }
    
    public void showMessage()
    {
        System.out.println(this.message);
    }
    
    public void handle()
    {
        this.getMessage();
        this.setMessage("25+10 = " + sum(25,10)) ;                
        this.setMessage("100+200 = " + sum(100,200));
    }
    
    public int sum(int a, int b)
    {
        return a+b ;
    }
    
    public int sub(int a, int b)
    {
        System.out.println("sub(" + a + ", " + b + ") = " + (a-b));
        return a-b ;
    } 
    
    
    public static void makeoAuthCall() {
        HttpHost proxy = new HttpHost("127.0.0.1", 8080, "http");

        DefaultHttpClient httpclient = new DefaultHttpClient();
        try {
            //httpclient.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, proxy);

            HttpHost target = new HttpHost("www.snapfish.com", 80, "http");
            HttpGet req = new HttpGet("/welcome");

            System.out.println("executing request to " + target + " via " + proxy);
            HttpResponse rsp = httpclient.execute(target, req);
            HttpEntity entity = rsp.getEntity();

            System.out.println("----------------------------------------");
            System.out.println(rsp.getStatusLine());
            Header[] headers = rsp.getAllHeaders();
            for (int i = 0; i<headers.length; i++) {
                System.out.println(headers[i]);
            }
            System.out.println("----------------------------------------");

            if (entity != null) {
                //System.out.println(EntityUtils.toString(entity));
                // Get the response
                /*
                BufferedReader rd = new BufferedReader
                  (new InputStreamReader(response.getEntity().getContent()));
                    
                String line = "";
                while ((line = rd.readLine()) != null) {
                  textView.append(line);
                } 
                */
            }

        }catch(Exception e){
            e.printStackTrace();
        }
        finally {
            // When HttpClient instance is no longer needed,
            // shut down the connection manager to ensure
            // immediate deallocation of all system resources
            httpclient.getConnectionManager().shutdown();
        }
    }
    
}
