function img2coe_resize(path,name,width,length)
    img=imread(path);
    np1=imresize(img,[width,length]);
    np2=bitshift(np1(:,:,:),-4);
    np3=cell(width,length,3);
    for k=1:3
        for j=1:length
            for i=1:width
                np3(i,j,k)=cellstr(dec2hex(np2(i,j,k),1));
            end
        end
    end
    file=fopen(name,'w+');
    fprintf(file,'memory_initialization_radix=16;\n');
    fprintf(file,'memory_initialization_vector=\n');
    cnt=0;
    for i=1:width
        for j=1:length
            for k=1:3
                fprintf(file,'%s',np3{i,j,k});
            end
            if i==width && j==length && k==3
                fprintf(file,';');
            else
                fprintf(file,',');
            end
            cnt=cnt+1;
        end
    end
    fclose(file);
end