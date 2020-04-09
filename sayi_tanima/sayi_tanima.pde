int[][] data;
int[] sampleSize={0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int padding=20;
int kareSize=10;
int dataX=15;
int dataY=20;
int altKisim=250;
int trainValue=-1;
Train networkTrainer;
ReadWriteFile rw;
ArrayList<ArrayList<Double>> istenenSonuc;
long trainTime=5000;
int result=-1, ikinci=-1;
double resultValue, ikinciValue;
boolean pressed=true;


void setup() {
  size(360, 410);
  // frame sizelarını denemek için dinamik yapmıştım, önemsiz şeyler
  println(padding*3 + 2*dataX*kareSize, padding*3+dataY*kareSize+altKisim);
  // surface.setSize(padding*3 + 2*dataX*kareSize, padding*3+dataY*kareSize+altKisim);   
  data= new int[dataX][dataY];
  dataSifirla();
  sablonCiz();
  istenenSonucDoldur();
  rw= new ReadWriteFile();
  networkTrainer=new Train();

  networkTrainer.train(trainTime);
}

void draw() {

  // Draw only when mouse is pressed
  if (mousePressed == true) {
    if ( mouseX>padding && mouseX<padding+dataX*kareSize && mouseY>padding && mouseY<padding+dataY*kareSize)
      data[(mouseX-padding)/kareSize][(mouseY-padding)/kareSize]=1;
    else if ( !pressed && mouseX> width/2+padding/2 && mouseX<width/2+padding/2+dataX*kareSize && mouseY>kareSize*dataY+2*padding && mouseY<kareSize*dataY+2*padding+dataX*kareSize/5*2) {
      int x= (mouseX-(width/2+padding/2))/(dataX*kareSize/5);
      int y= (mouseY-(kareSize*dataY+2*padding))/(dataX*kareSize/5);
      trainValue=x+y*5;
      networkTrainer.addTrainingSet(new TrainingSet(duzArrayGetir(), istenenSonuc.get(trainValue)));
      rw.saveToFile(duzArrayGetir(), trainValue+"");
      networkTrainer.train(trainTime);
      sampleSize[trainValue]++;
      pressed=true;
    }
  }

  sablonCiz();
}

void keyPressed() {

  if (keyCode==ENTER) {
    networkTrainer.setInputs(duzArrayGetir());
    ArrayList<Double> outputs = networkTrainer.getOutputs();
    int index1 = 0, index2=0;
    double high1=0, high2=0, total=0;

    for (int i = 0; i < outputs.size(); i++) {
      total+=outputs.get(i);
      if (outputs.get(i) > high1) {
        high2=high1;
        index2=index1;
        high1=outputs.get(i);
        index1=i;
      } else if (outputs.get(i) > high2) {
        high2 = outputs.get(i);
        index2=i;
      }
    }
    result=index1;
    resultValue=outputs.get(index1)/total;
    ikinci=index2;
    ikinciValue=outputs.get(index2)/total;



    pressed=false;
  }
  if (keyCode==BACKSPACE) {
    dataSifirla();
    trainValue=-1;
    result=-1;
    resultValue=0.0;
    ikinci=-1;
    ikinciValue=0.0;
    pressed=false;
  }
}

void sablonCiz() {
  background(0);
  fill(250);
  for (int i=0; i<dataX; i++)
    for (int j=0; j<dataY; j++) {
      if (data[i][j]==1)
        fill(200, 0, 0);
      else
        fill(250);
      rect(padding+kareSize*i, padding+kareSize*j, kareSize, kareSize);
    }

  fill(250);
  rect(width/2+padding/2, padding, kareSize*dataX, kareSize*dataY);
  fill(150);  

  if (result>-1) {
    textSize(20);
    text("["+result+"] : % " +(int)(resultValue*100)+"\n["+ikinci+"] : % " +(int)(ikinciValue*100), padding, padding+dataY*kareSize*1.2);

    textSize(dataY*kareSize);
    text(result, width/2+padding/2, padding+dataY*kareSize*0.9);
  }

  fill(200, 0, 0);
  textSize(14);
  text("Öğretmek için seç:", width/2+padding/2, kareSize*dataY+2*padding-5);
  text("En iyi 2 sonuç:", padding, kareSize*dataY+2*padding-5);
  text("Construction data size:", padding, height-80);

  for (int i=0; i<5; i++) {
    fill(0, 200, 0);
    if (trainValue==i)
      fill(150, 150, 0);    
    rect(width/2+padding/2+ i*dataX*kareSize/5, kareSize*dataY+2*padding, dataX*kareSize/5, dataX*kareSize/5);  
    fill(0, 200, 0);
    if (trainValue==i+5)
      fill(150, 150, 0);
    rect(width/2+padding/2+ i*dataX*kareSize/5, kareSize*dataY+2*padding +dataX*kareSize/5, dataX*kareSize/5, dataX*kareSize/5);
    fill(250);
    textSize(dataX*kareSize/5);
    text(i, width/2+padding/2+ (i+0.2)*dataX*kareSize/5, kareSize*dataY+2*padding+dataX*kareSize/5*0.9);
    text(i+5, width/2+padding/2+ (i+0.2)*dataX*kareSize/5, kareSize*dataY+2*padding+dataX*kareSize/5*1.9);
  }
  for (int i=0; i<10; i++) {
    textSize(14);
    fill(0, 0, 200);
    text("["+i+"]: "+sampleSize[i], padding + 70*(i%5), height-60+20*(i/5));
  }
  textSize(10);
  fill(200, 200, 0);
  text("ENTER: Tahmin Yaptırır        BACKSPACE: Çizimi Temizler", padding, height-10);
}

void dataSifirla() {
  for (int i=0; i<dataX; i++)
    for (int j=0; j<dataY; j++)
      data[i][j]=0;
}

double sigmoidValue(Double arg) {
  return (1 / (1 + Math.exp(-arg)));
}

/*  çizilen şekli tutan arrayi tek boyutlu yapar
 *  Ör: 110  
 *      000  ise yeni array: 110000111 olur
 *      111
 */

ArrayList<Integer> duzArrayGetir() {
  ArrayList<Integer> temp= new ArrayList<Integer>();
  for (int i=0; i<dataY; i++)
    for (int j=0; j<dataX; j++)
      temp.add(data[j][i]);
  return temp;
}

// istenen sonuçları doldurur.. 0-> 1000... 1-> 0100... 2-> 001000...
void istenenSonucDoldur() {
  istenenSonuc= new ArrayList<ArrayList<Double>>();
  for (int i=0; i<10; i++) {
    ArrayList<Double> temp= new ArrayList<Double>();
    int cnt=0;
    while (cnt<i) {
      temp.add((double)0);
      cnt++;
    }
    temp.add((double)1);
    cnt++;
    while (cnt<10) {
      temp.add((double)0);
      cnt++;
    }
    istenenSonuc.add(temp);
  }
}


//-------------------------------------------------------------------------------------

class Neuron {

  int BIAS = 1;
  double LEARNING_RATIO = 0.1;

  ArrayList<Integer> inputs;
  ArrayList<Double> weights;
  double biasWeight;
  double output;

  public Neuron() {
    this.inputs = new ArrayList<Integer>();
    this.weights = new ArrayList<Double>();
    this.biasWeight = Math.random();
  }

  void setInputs(ArrayList<Integer> inputs) {
    if (this.inputs.size() == 0) {
      this.inputs = new ArrayList<Integer>(inputs);
      generateWeights();
    }
    this.inputs = new ArrayList<Integer>(inputs);
  }

  // random weightler alınır
  void generateWeights() {
    for (int i = 0; i < inputs.size(); i++)
      weights.add(Math.random());
  }

  /*  tüm weightler öğrenme oranı, error ve BIAS a göre değişir
   *  error negatifse (istenen sonuç değilse) weightler azalır
   *  error pozitifse (istenen sonuç ise) weightler artar
   */
  void weightDuzenle(double error) {
    for (int i = 0; i < inputs.size(); i++) {
      double d = weights.get(i);
      d += LEARNING_RATIO * error * inputs.get(i);
      weights.set(i, d);
    }
    biasWeight += LEARNING_RATIO * error * BIAS;
  }

  /*  tüm nöranların dataları ve Bias kendi weightleri ile çarpılıp toplanır
   *  elde edilen sonuç sigmoid value olarak output olur ( 0-1 aralığında outputlar )
   *  sigmoid value: weightlerin az değişirken outputun aşırı değişmesini engeller.   1/(1+e^(-output))  
   */
  double getOutput() {
    double sum = 0;
    for (int i = 0; i < inputs.size(); i++) {
      sum += inputs.get(i) * weights.get(i);
    }
    sum += BIAS * biasWeight;
    output = sigmoidValue(sum);
    return output;
  }
}

//-------------------------------------------------------------------------------------

class Network {

  ArrayList<Neuron> neurons;

  Network() {
    neurons = new ArrayList<Neuron>();
  }

  void addNeurons(int count) {
    for (int i = 0; i < count; i++)
      neurons.add(new Neuron());
  }

  void setInputs(ArrayList<Integer> inputs) {
    for (Neuron n : neurons)
      n.setInputs(inputs);
  }

  ArrayList<Double> getOutputs() {
    ArrayList<Double> outputs = new ArrayList<Double>();
    for (Neuron n : neurons)
      outputs.add(n.getOutput());
    return outputs;
  }

  // tüm nöranların outputlarını istenen sonuçtan çıkarır ve aradaki fark (error) ile weightler düzenlenir
  void puanla(ArrayList<Double> istenenSonuclar) {
    for (int i = 0; i < neurons.size(); i++) {
      double error = istenenSonuclar.get(i) - neurons.get(i).getOutput();
      neurons.get(i).weightDuzenle(error);
    }
  }
}
//-------------------------------------------------------------------------------------

class Train {

  Network network;
  ArrayList<TrainingSet> trainingSets;

  // Network, 10 nöron ve tüm training setleri hazırlar
  Train() {
    this.network = new Network();
    this.network.addNeurons(10);
    this.trainingSets = rw.readTrainingSets();
  }

  // tüm training setlerden random olarak count kadarını seçer ve sırayla networküne dahil eder;
  // tüm nöranları inputla doldurur, outputları da alıp puanlar
  void train(long count) {
    for (long i = 0; i < count; i++) {
      int index = ((int) (Math.random() * trainingSets.size()));
      TrainingSet set = trainingSets.get(index);
      network.setInputs(set.getInputs());
      network.puanla(set.getIstenenSonuc());
    }
  }

  void setInputs(ArrayList<Integer> inputs) {
    network.setInputs(inputs);
  }

  void addTrainingSet(TrainingSet newSet) {
    trainingSets.add(newSet);
  }

  ArrayList<Double> getOutputs() {
    return network.getOutputs();
  }
}
//-------------------------------------------------------------------------------------

class ReadWriteFile {
  /*  Tüm fileların içindeki tüm dataları file adına göre istenen sonuçlarla beraber Training set oluşturup listeler.
   *  Örnek: 1.txt'den;   input: 1000010001111...    istenen sonuç: 0100000000
   *         3.txt'den;   input: 0000100011011...    istenen sonuç: 0001000000
   *         3.txt'den;   input: 1110010001101...    istenen sonuç: 0001000000                                             
   */
  ArrayList<TrainingSet> readTrainingSets() {
    ArrayList<TrainingSet> trainingSets = new ArrayList<TrainingSet>();
    for (int i = 0; i < 10; i++)     
      for (ArrayList<Integer> list : readFromFile(i))
        trainingSets.add(new TrainingSet(list, istenenSonuc.get(i)));

    return trainingSets;
  }

  /* istenen file içindeki dataları satırlara ayırıp listeler. Training set için input hazırlar.
   *  Örnek: 2.txt içinde;
   *  1. satır-> 0000100001111000.... (Arraylist<Integer>)
   *  2. satır-> 0111000001011000....
   *  .....
   *  hepsini arrayliste alır
   */
  ArrayList<ArrayList<Integer>> readFromFile(int num) {
    ArrayList<ArrayList<Integer>> inputs = new ArrayList<ArrayList<Integer>>();
    String filename="datalar/" + num + ".txt";
    sampleSize[num]=0;
    try {
      BufferedReader reader = createReader(filename); 
      String line;
      while ((line = reader.readLine()) != null) {
        sampleSize[num]++;
        ArrayList<Integer> input = new ArrayList<Integer>();
        for (int i = 0; i < line.length(); i++) {
          input.add(Character.getNumericValue(line.charAt(i)));
        }
        inputs.add(input);
      }
      reader.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    return inputs;
  }

  // öğretilen veriyi filea yeni satır olarak ekler
  void saveToFile(ArrayList<Integer> input, String filename) {
    try {
      String[] lines = loadStrings("datalar/" + filename + ".txt");
      PrintWriter pw = createWriter("datalar/" + filename + ".txt");
      for (int i = 0; i < lines.length; i++) {
        pw.println(lines[i]);
      }
      for (Integer i : input) {
        pw.write(Integer.toString(i));
      }
      pw.write("\n");
      pw.close();
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}

//-------------------------------------------------------------------------------------

class TrainingSet {

  ArrayList<Integer> inputs;
  ArrayList<Double> istenenSonuc;

  TrainingSet(ArrayList<Integer> inputs, ArrayList<Double> istenenSonuc) {
    this.inputs = inputs;
    this.istenenSonuc = istenenSonuc;
  }

  ArrayList<Integer> getInputs() {
    return inputs;
  }

  ArrayList<Double> getIstenenSonuc() {
    return istenenSonuc;
  }
}

//-------------------------------------------------------------------------------------