FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
#criando working directory dentro do container
WORKDIR /app  
#porta de saídaa
EXPOSE 5194

ENV ASPNETCORE_URLS=http://+:5194

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
#copiando o arquivo webAppDocker.csproj para ./
COPY ["webAppDocker.csproj", "./"]
RUN dotnet restore "webAppDocker.csproj"
#copiando todos arquivos do diretório /app
COPY . .
WORKDIR "/src/."
RUN dotnet build "webAppDocker.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "webAppDocker.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "webAppDocker.dll"]
