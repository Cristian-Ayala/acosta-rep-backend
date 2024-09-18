import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/cloudfront-signer";
import { Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { v4 as uuidv4 } from "uuid";
import { Response } from "express";
import { Readable } from "stream";
import loggerService from "../../logger.service";
import { Upload } from "@aws-sdk/lib-storage";

@Injectable()
export class FileManagerService {
  private readonly s3Client = new S3Client({
    region: this.configService.getOrThrow("AWS_S3_REGION"),
  });

  private readonly cloudFrontDomain = this.configService.getOrThrow(
    "AWS_CLOUDFRONT_DOMAIN",
  ); // Add CloudFront domain

  constructor(private readonly configService: ConfigService) {}

  async processUploadedFiles(
    files: Express.Multer.File[],
    userId: string,
  ): Promise<ProcessedFilesResult> {
    if (!files || files.length === 0)
      return {
        errors: ["No files found"],
        savedFileNames: null,
        savedFilesOriginalNames: null,
      };

    // Store filenames used for S3 uploads and track successful uploads
    const successfulUploads: { originalName: string; uniqueName: string }[] =
      [];
    const errors: string[] = [];

    const uploadPromises = files.map(async (file) => {
      const uniqueFilename = `${uuidv4()}_${file.originalname}`;
      const tmpFile = { name: uniqueFilename, userId };
      loggerService.log(`Uploading File: ${JSON.stringify(tmpFile)}`);

      const fileStream = Readable.from(file.buffer);

      try {
        await new Upload({
          client: this.s3Client,
          params: {
            Bucket: this.configService.getOrThrow("AWS_S3_BUCKET_NAME"),
            Key: uniqueFilename,
            Body: fileStream,
            ContentType: file.mimetype,
          },
        }).done();

        // Track successful uploads
        successfulUploads.push({
          originalName: file.originalname,
          uniqueName: uniqueFilename,
        });
      } catch (error) {
        loggerService.error("Error uploading file to S3:", error);
        errors.push(`Failed to upload ${file.originalname}`);
      }
    });

    await Promise.all(uploadPromises);

    return {
      errors: errors.length > 0 ? errors : null,
      savedFileNames: successfulUploads.map((file) => file.uniqueName),
      savedFilesOriginalNames: successfulUploads.map(
        (file) => file.originalName,
      ),
    };
  }

  // Generate CloudFront URL for a given file
  async getCloudFrontUrl(filename: string): Promise<string> {
    return getSignedUrl({
      url: `https://${this.cloudFrontDomain}/${filename}`,
      keyPairId: this.configService.getOrThrow("AWS_CLOUDFRONT_KEY_PAIR_ID"),
      privateKey: this.configService.getOrThrow("AWS_CLOUDFRONT_PRIVATE_KEY"),
      dateLessThan: new Date(Date.now() + 1000 * 60 * 60 * 24).toString(), // 24 hours
    });
  }

  async serveDefaultPhoto(res: Response): Promise<void> {
    await this.servePhoto("default.jpg", res);
  }

  async servePhoto(filename: string, res: Response): Promise<void> {
    try {
      const cloudFrontUrl = await this.getCloudFrontUrl(filename);
      res.redirect(cloudFrontUrl);
    } catch (error) {
      loggerService.error("Error generating CloudFront URL:", error);
      res.status(500).send("Error retrieving photo");
    }
  }
}

export interface ProcessedFilesResult {
  errors: string[] | null;
  savedFileNames: string[] | null;
  savedFilesOriginalNames: string[] | null;
}
