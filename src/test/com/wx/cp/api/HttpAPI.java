package com.wx.cp.api;
import org.junit.Test;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

public class HttpAPI {

    @Test
    public void test() {
        LocalDate now = LocalDate.now();
        now.getMonth().toString();
        //判断当前年份是平年还是闰年
        int i = now.lengthOfMonth();
        System.out.println(i);
        Month month = now.getMonth();
        if (now.isLeapYear()) {
            System.out.println("111");
        }
        System.out.println(now.getMonth());
        System.out.println(now.toString());
        System.out.println(now.minusDays(1));
        System.out.println(now.minusMonths(1));
//        CurrentMonth date = getDate(now.getMonth());
//        System.out.println(date);
        System.out.println(now.plusDays(9));
        CurrentDateTime date = getDay();
        System.out.println(date);

        CurrentDateTime currentWeek = getCurrentWeek();
        System.out.println(currentWeek);
    }

    public CurrentDateTime getMonthStartAndEndDate() {
        CurrentDateTime currentDateTime = new CurrentDateTime();
        LocalDate now = LocalDate.now();
        int year = now.getYear();
        int days = now.lengthOfMonth();
        Month month = now.getMonth();
        int nowMonth = now.getMonth().getValue();
        switch (month) {
            case JANUARY:
            case DECEMBER:
            case FEBRUARY:
            case MARCH:
            case APRIL:
            case MAY:
            case JUNE:
            case JULY:
            case AUGUST:
            case SEPTEMBER:
            case OCTOBER:
            case NOVEMBER: {
                currentDateTime.setStartDate(year + "-" + nowMonth + "-01");
                currentDateTime.setEndDate(now.toString());
                return currentDateTime;
            }
        }
        return null;
    }

    public CurrentDateTime getDay(){
        LocalDate now = LocalDate.now();
        CurrentDateTime currentDateTime = new CurrentDateTime();
        currentDateTime.setStartDate(now.minusDays(1).toString());
        currentDateTime.setEndDate(now.toString());
        return currentDateTime;
    }

    public CurrentDateTime getCurrentWeek(){
        LocalDate now = LocalDate.now();
        CurrentDateTime currentDateTime = new CurrentDateTime();
        currentDateTime.setStartDate(now.minusDays(6).toString());
        currentDateTime.setEndDate(now.toString());
        return currentDateTime;
    }

    @Test
    public void test1(){
        LocalDate now = LocalDate.now();
        String strDate = "2019-07-31";
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate startDate = LocalDate.parse(strDate, dateTimeFormatter);
        long period = now.toEpochDay() - startDate.toEpochDay();
        System.out.println(now.plusDays(120));
        System.out.println(period);

        BigDecimal bigDecimal = new BigDecimal("-11");
        BigDecimal bigDecima1l = new BigDecimal("0");
        BigDecimal bigDecimal2 = new BigDecimal("12");
        int i1 = bigDecimal.compareTo(BigDecimal.ZERO);
        int i2 = bigDecima1l.compareTo(BigDecimal.ZERO);
        int i3 = bigDecimal2.compareTo(BigDecimal.ZERO);
        System.out.println(i1);
        System.out.println(i2);
        System.out.println(i3);

        LocalDate of = LocalDate.of(2019, 6, 10);
        LocalDate of1 = LocalDate.of(2019,12,12);
        long until = of.until(of1, ChronoUnit.DAYS);
        System.out.println(until);
    }

    @Test
    public void test2(){
        List<Product> productList = new ArrayList<>();
        productList.add(new Product(1, new BigDecimal(60), 50));
        productList.add(new Product(2, new BigDecimal(70), 30));
        productList.add(new Product(3, new BigDecimal(80), 10));
        productList.add(new Product(4, new BigDecimal(75), 55));
        productList.add(new Product(5, new BigDecimal(30), 70));
        productList.add(new Product(5, new BigDecimal(75), 60));
        //按照价格从小到大排序，如果价格相等，则按照剩余数量从小到大排序
        productList.sort((o1, o2) -> {
            if (o1.getPrice().compareTo(o2.getPrice()) == 0) {
                if (o1.getNum() >= o2.getNum()) {
                    return 1;
                }
                return -1;
            }
            return o1.getPrice().compareTo(o2.getPrice());
        });
        for (Product product : productList) {
            System.out.println(product.toString());
        }

        BigDecimal bigDecimal = new BigDecimal("1.00");
        System.out.println(bigDecimal.toString());

    }

    @Test
    public void testMoney(){
        BigDecimal decimal = new BigDecimal("0.130266");
        BigDecimal divisor = new BigDecimal("2422198");
        BigDecimal trade = divisor.divide(decimal,2,RoundingMode.HALF_UP);
        System.out.println(trade);
        //将BigDecimal类型值转成百分数
        NumberFormat percent = NumberFormat.getPercentInstance();
        percent.setMaximumFractionDigits(3);
        String percentage = percent.format(decimal.doubleValue());
        System.out.println("百分数 = " + percentage);
        LocalDateTime date = LocalDateTime.now();
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        //使用LocalDateTime获取本月的第一天
        LocalDateTime firstDay = date.with(TemporalAdjusters.firstDayOfMonth());
        System.out.println(firstDay.format(dateTimeFormatter));
        //使用LocalDateTime获取本月的最后一天
        LocalDateTime lastDay = date.with(TemporalAdjusters.lastDayOfMonth());
        //计算时间类型为LocalDateTime月初与当前时间的时间间隔
        System.out.println("计算时间类型为LocalDateTime月初与当前时间的时间间隔" + firstDay.until(date, ChronoUnit.DAYS));
        System.out.println("计算时间类型为LocalDateTime月初与月末的时间间隔" + firstDay.until(lastDay, ChronoUnit.DAYS));
        CurrentDateTime date1 = getMonthStartAndEndDate();
        System.out.println(date1.getStartDate());
        System.out.println(date1.getEndDate());
        System.out.println(lastDay.format(dateTimeFormatter));

        CurrentDateTime currentDateTime = new CurrentDateTime();
        boolean wechatFlag = currentDateTime.isWechatFlag();
        System.out.println("boolean默认值是：" + wechatFlag);

        LocalDate now = LocalDate.now();
        //使用LocalDate获取本月的第一天
        LocalDate firstDayOfMonth = now.with(TemporalAdjusters.firstDayOfMonth());
        //使用LocalDate获取本月的最后一天
        LocalDate lastDayOfMonth = now.with(TemporalAdjusters.lastDayOfMonth());
        //当前时间前30天
        LocalDate startDate = now.minusDays(30);

        System.out.println("当前时间前29天日期：" + startDate);
        //计算月初与当前时间的时间间隔
        System.out.println("计算时间类型为LocalDate月初与当前时间的时间间隔：" + firstDayOfMonth.until(now, ChronoUnit.DAYS));
        System.out.println("计算时间类型为LocalDate月初与月末的时间间隔：" + firstDayOfMonth.until(lastDayOfMonth, ChronoUnit.DAYS));
    }

    @Test
    public void testString(){
        String  str = "农夫|迪奥|魅可";
        String[] split = str.split("\\|");
//        for (String s : split) {
//            System.out.println(s);
//        }
        StringBuilder stringBuilder = new StringBuilder();
        for (String st : split) {
            stringBuilder.append("'");
            stringBuilder.append(st);
            stringBuilder.append("',");
        }
        String substring=stringBuilder.toString();
        substring=substring.substring(0,substring.lastIndexOf(","));
        System.out.println("substring = "+substring);
//        System.out.println(testStr1(str));
//        List<String> strList = new ArrayList<>();
//        strList.add("111");
//        strList.add("222");
//        strList.add("333");
//        ArrayList<Object> objects = new ArrayList<>(strList);
//        for (Object object : objects) {
//            System.out.println(object);
//        }
        BigDecimal a = new  BigDecimal("1111111111111111111111111.1111", new MathContext(3, RoundingMode.HALF_UP));//构造BigDecimal时指定有效精度
        System.out.println(a.toEngineeringString());//然后使用toEngineeringString
        //需求：加入千分位.
        DecimalFormat df = new DecimalFormat("###,###");
        //开始格式化
        System.out.println(df.format(1234567)); //"1,234,567"

        //需求：加入千分位，保留2位小数
        DecimalFormat df1 = new DecimalFormat("###,###.##");
        System.out.println(df1.format(1234567.123)); //"1,234,567.12"
        System.out.println(number(20));
    }

    public boolean testStr1(String str){
        return str.contains("|");
    }

    public boolean number(int number){
        if (20 != number){
            return true;
        }
        return false;
    }

    /**
     * 高:12 长:6 宽 6
     *
     * @return
     */
    @Test
    public void number() {
//        int all = 12 * 6 * 6 * 288;
//        for (int i = 0; i < 80; i++) {
//            for (int j = 0; j < 80; j++) {
//                for (int k = 0; k < 80; k++) {
//                    if (i * j * k == all) {
//                        if (i > 6 || j > 6 || k > 12) {
//                            System.out.println("长=" + i + " 宽=" + j + " 高=" + k);
//                        }
//                    }
//                }
//            }
//        }
//        int a = 60*50*40-12*6*6*288;
//        BigDecimal abs = new BigDecimal(""+a);
//        int b = 12*6*6;
//        BigDecimal abd = new BigDecimal(""+b);
//        System.out.println("a = "+a);
//        System.out.println("b = "+b);
//        System.out.println(abs.divide(abd,2,RoundingMode.HALF_UP));

        System.out.println(10176-2969+4934-4688);
        System.out.println(2579480.32-734724.14+1244507.83-1189962.27);

        BigDecimal a = new BigDecimal("10.176");
        BigDecimal b = new BigDecimal("29.69");
        BigDecimal c = new BigDecimal("49.34");
        System.out.println(a.add(b).subtract(c).setScale(2,RoundingMode.HALF_UP));

    }


}
