/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;

import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
//import javax.imageio.stream.ImageOutputStream;
import javax.imageio.stream.MemoryCacheImageOutputStream;
import java.io.InputStream;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.IIOImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;


/**
 *
 * @author markzampoglou
 */
public class JavaRecompressor {

    BufferedImage CurrentImage;

    public JavaRecompressor(Image ImIn) {
        CurrentImage = toBufferedImage(ImIn);
    }

    public Image RecompressImage(java.lang.Double Quality) {
        //Apply in-memory JPEG compression to a BufferedImage given a Quality setting (0-100)
        //and return the resulting BufferedImage

           
            float FQuality = (float) (Quality / 100.0);

            //File OutputFile = new File("TestOutput.jpg");
            BufferedImage OutputImage = null;
            try {
                ImageWriter writer;
                Iterator<ImageWriter> iter = ImageIO.getImageWritersByFormatName("jpeg");
                writer = iter.next();
                ImageWriteParam iwp = writer.getDefaultWriteParam();
                iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                iwp.setCompressionQuality(FQuality);

                byte[] imageInByte;
                try ( //ImageOutputStream ios = ImageIO.createImageOutputStream(OutputFile);
                        ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                    MemoryCacheImageOutputStream mcios = new MemoryCacheImageOutputStream(baos);
                    //writer.setOutput(ios);
                    writer.setOutput(mcios);
                    IIOImage tmptmpImage = new IIOImage(CurrentImage, null, null);
                    writer.write(null, tmptmpImage, iwp);
                    writer.dispose();
                    baos.flush();
                    imageInByte = baos.toByteArray();
                }
                InputStream in = new ByteArrayInputStream(imageInByte);
                OutputImage = ImageIO.read(in);
            } catch (Exception ex) {
                Logger.getLogger(JavaRecompressor.class.getName()).log(Level.SEVERE, null, ex);
            }
        

        return OutputImage;
    }

    public static BufferedImage toBufferedImage(Image img) {
        if (img instanceof BufferedImage) {
            return (BufferedImage) img;
        }

        // Create a buffered image with transparency
        BufferedImage bimage = new BufferedImage(img.getWidth(null), img.getHeight(null), BufferedImage.TYPE_INT_ARGB);

        // Draw the image on to the buffered image
        Graphics2D bGr = bimage.createGraphics();
        bGr.drawImage(img, 0, 0, null);
        bGr.dispose();

        // Return the buffered image
        return bimage;
    }
}
