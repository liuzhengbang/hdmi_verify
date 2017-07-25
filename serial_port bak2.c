#include <sys/types.h>  
  
#include <sys/stat.h>  
#include <fcntl.h>  
#include <termios.h>  
#include <stdio.h> 
#include <time.h> 
#define BAUDRATE        (B9600)  
#define UART_DEVICE     ("/dev/ttyAMA0")
#define DATA_LENGTH (8)
  
#define FALSE  -1  
#define TRUE   0  
////////////////////////////////////////////////////////////////////////////////  
/** 
*@brief  设置串口通信速率 
*@param  fd     类型 int  打开串口的文件句柄 
*@param  speed  类型 int  串口速度 
*@return  void 
*/  
int speed_arr[] = {B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300,  
                   B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300, };  
int name_arr[] = {115200, 38400, 19200, 9600, 4800, 2400, 1200,  300,   
                  115200, 38400, 19200, 9600, 4800, 2400, 1200,  300, };  
void set_speed(int fd, int speed){  
  int   i;   
  int   status;   
  struct termios   Opt;  
  tcgetattr(fd, &Opt);   
  cfmakeraw   (&Opt) ;
  for ( i= 0;  i < sizeof(speed_arr) / sizeof(int);  i++) {   
    if  (speed == name_arr[i]) {       
      tcflush(fd, TCIOFLUSH);       
      cfsetispeed(&Opt, speed_arr[i]);    
      cfsetospeed(&Opt, speed_arr[i]);     
      status = tcsetattr(fd, TCSANOW, &Opt);    
      if  (status != 0) {          
        perror("tcsetattr fd1");    
        return;       
      }      
      tcflush(fd,TCIOFLUSH);     
    }    
  }  
}  
////////////////////////////////////////////////////////////////////////////////  
/** 
*@brief   设置串口数据位，停止位和效验位 
*@param  fd     类型  int  打开的串口文件句柄 
*@param  databits 类型  int 数据位   取值 为 7 或者8 
*@param  stopbits 类型  int 停止位   取值为 1 或者2 
*@param  parity  类型  int  效验类型 取值为N,E,O,,S 
*/  
int set_Parity(int fd,int databits,int stopbits,int parity)  
{   
    struct termios options;   
    if  ( tcgetattr( fd,&options)  !=  0) {   
        perror("SetupSerial 1");       
        return(FALSE);    
    }  
    cfmakeraw   (&options) ;
    cfsetispeed (&options, B9600) ;
    cfsetospeed (&options, B9600) ;

    options.c_cflag |= (CLOCAL | CREAD) ;
    options.c_cflag &= ~PARENB ;
    options.c_cflag &= ~CSTOPB ;
    options.c_cflag &= ~CSIZE ;
    options.c_cflag |= CS8 ;
    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG) ;
    options.c_oflag &= ~OPOST ;

    options.c_cc [VMIN]  =   0 ;
    options.c_cc [VTIME] = 100 ;    /* Update the options and do it NOW */  
    if (tcsetattr(fd,TCSANOW,&options) != 0)     
    {   
        perror("SetupSerial 3");     
        return (FALSE);    
    }   

    //options.c_lflag  &= ~(ICANON | ECHO | ECHOE | ISIG);  /*Input*/  
    options.c_lflag  &= ~(ICANON | ECHO | ECHOE | ISIG);
    options.c_oflag  &= ~OPOST;   /*Output*/  
    return (TRUE);    
}  
////////////////////////////////////////////////////////////////////////////////  

void search_header(int fd);

int main(int argc, char *argv[])  
{  
  
    int    fd, c=0, res;  
    time_t t;
    unsigned char  buf[DATA_LENGTH];  

    FILE *hdmi_fp; 
    FILE *pulse_fp; 
    FILE *error_fp; 

    hdmi_fp=fopen("hdmi.csv","a+");
    pulse_fp=fopen("pulse.csv","a+");
    error_fp=fopen("error.csv","a+");
    fseek(hdmi_fp, 0, SEEK_END);
    fseek(pulse_fp, 0, SEEK_END);
    fseek(error_fp, 0, SEEK_END);




    printf("Start...\n");  
    fd = open(UART_DEVICE, O_RDWR | O_NOCTTY | O_NDELAY | O_NONBLOCK);  
    fcntl (fd, F_SETFL, O_RDWR) ;
  
    if (fd < 0) {  
        perror(UART_DEVICE);  
        //exit(1);  
    }  
  
    printf("Open...\n");  
    set_speed(fd,9600);  
    if (set_Parity(fd,8,1,'N') == FALSE)  {  
        printf("Set Parity Error\n");  
        //exit (0);  
    }  
  
    printf("Reading...\n");  

    time(&t);

    fprintf(hdmi_fp,"%s,%s,%s","DELAY","ERROR COUNT",ctime(&t));
    fflush(hdmi_fp);
    fprintf(pulse_fp,"%s,%s,%s","DELAY","PULSE VARIANCE",ctime(&t));
    fflush(pulse_fp);
    fprintf(error_fp,"%s,%s,%s","ERROR CODE (0x10:PIXEL )","DESCRIPT",ctime(&t));
    fflush(error_fp);

    while(1) {
        res = 0;
        search_header(fd);

        do{
            res += read(fd, buf+res, DATA_LENGTH-res);
        }while(res < DATA_LENGTH);
        //printf("%02X %02X %02X %02X %02X %02X %02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5],buf[6]);

        time(&t);
        if(buf[0] == 0x00)
        {
            fprintf(hdmi_fp,"=\"%02X%02X%02X\",=\"%02X\",%s",buf[1],buf[2],buf[3],buf[4],ctime(&t));
            fflush(hdmi_fp);
        }
        else if(buf[0] == 0x01)
        {
            //fprintf(pulse_fp,"=\"%02X%02X%02X\",=\"%02X%02X%02X\",%s",buf[1],buf[2],buf[3],buf[4],buf[5],buf[6],ctime(&t));
	        //fprintf(pulse_fp,"=\"%ld\",=\"%ld\",%s",(long)((buf[1]<<24)+(buf[2]<<16)+(buf[3]<<8)+buf[4]),(long)((buf[5]<<16)+(buf[6]<<8)+buf[7]),ctime(&t));
            fprintf(pulse_fp,"=\"%ld\",=\"%02X%02X%02X\",%s",(long)((buf[1]<<24)+(buf[2]<<16)+(buf[3]<<8)+buf[4]),buf[5],buf[6],buf[7],ctime(&t));
            fflush(pulse_fp);
        }
        else if(buf[0] == 0x10)
        {
            //printf("%02X %02X %02X %02X %02X %02X %02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5],buf[6]);
            fprintf(error_fp,"%s,=\"%02X%02X\",=\"%02X%02X\",=\"%02X\",=\"%02X\",=\"%02X\",%s","BAD PIXEL",buf[1],buf[2],buf[3],buf[4],buf[5],buf[6],buf[7],ctime(&t));
            fflush(error_fp);
        }
        else if(buf[0] == 0x11)
        {
            //fprintf(error_fp,"%02X %02X %02X %02X %02X %02X %02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5],buf[6]);
            fprintf(error_fp,"%s,%s","FRAME LOST",ctime(&t));
            fflush(error_fp);
        }
        else if(buf[0] == 0x12)
        {
            fprintf(error_fp,"%s,%s","NOISE DETECTED",ctime(&t));
            fflush(error_fp);
        }
        else if(buf[0] == 0x13)
        {
            fprintf(error_fp,"%s,%s","PULSE NOT RECEIVED",ctime(&t));
            fflush(error_fp);
        }
        //printf("%02X %02X, %02X%1X,%01X%02X\n",buf[0],buf[1],buf[2],buf[3]>>4,buf[3]&(0x0f),buf[4]);
    }  
  
    printf("Close...\n");  
    close(fd);  
  
    return 0;  
}  

void search_header(int fd)
{
    unsigned char lb1 = 0;
    unsigned char lb2 = 0;
    do
    {
        lb1 = lb2;
        while(lb1 != 0x4D)
        {
            read(fd, &lb1, 1);
            //printf("%02X %02X  \n", lb1,lb2); 
        }
        read(fd, &lb2, 1);
        //printf("%02X %02X  \n", lb1,lb2); 
    }while(lb2 != 0x43);
}










