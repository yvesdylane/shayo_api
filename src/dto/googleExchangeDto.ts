import { IsString, IsNotEmpty } from 'class-validator';

export class GoogleExchangeDto {
  @IsString()
  @IsNotEmpty()
  token: string;
}
